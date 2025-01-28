// page_tracer.bpf.c
#include "vmlinux.h"
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include <bpf/bpf_core_read.h>

#define PAGE_SHIFT     12
#define PAGE_SIZE      (1UL << PAGE_SHIFT)

struct event {
    // Timestamp in ns
    u64 ts;
    u64 virt_addr;
    u64 phys_addr;
    u32 pid;
    // command name
    char comm[16]; //NOTE(silver): Fix this to not overflow.
    // 0: alloc, 1: fault, 2: free
    u32 event_type;
    // size of a memory allocation in terms of power-of-2 pages
    u32 order;
    // size in bytes for allocations
    u64 size;
};

struct {
    __uint(type, BPF_MAP_TYPE_ARRAY);
    __uint(max_entries, 1);
    __type(key, u32);
    __type(value, u32);
} target_pid SEC(".maps");

struct {
    __uint(type, BPF_MAP_TYPE_LRU_HASH);
    __uint(max_entries, 100000);
    __type(key, u64);     // physical address
    __type(value, struct page_info);
} page_lifecycle SEC(".maps");

// NOTE(silver): Does not need to be a struct but in future we might want to add more fields
// to track page perms/flags etc. 
struct page_info {
    u64 alloc_ts;       // Not the most accurate timestamp, but good enough for this example
    u32 fault_count;
};

struct {
    __uint(type, BPF_MAP_TYPE_RINGBUF);
    __uint(max_entries, 1024 * 1024); // 1MB buffer
} events SEC(".maps");


SEC("tp/kmem/mm_page_alloc")
int trace_page_alloc(struct trace_event_raw_mm_page_alloc *ctx)
{
    struct event *e;
    u64 phys_addr;
    u32 pid = bpf_get_current_pid_tgid() >> 32;
    
    // There will be only one element in the target_pid map
    u32 key = 0;
    u32 *target_pid_ptr;
    
    target_pid_ptr = bpf_map_lookup_elem(&target_pid, &key);

    // If the target_pid_ptr is NULL
    // If the target_pid is not 0 and not equal to the current pid skip the event
    if (!target_pid_ptr || (*target_pid_ptr != 0 && *target_pid_ptr != pid))
        return 0;
    
    // Reserve space in the ring buffer for an event structure defined above
    e = bpf_ringbuf_reserve(&events, sizeof(*e), 0);
    if (!e)
        return 0;

    // Populate the event structure with details about the allocated page
    // form the context
    phys_addr = ((u64)ctx->pfn) << PAGE_SHIFT;
    e->phys_addr = phys_addr;
    // We do not know yet here since the assignment did not happen yet 
    // See https://www.kernel.org/doc/Documentation/trace/events-kmem.txt
    // mm_page_alloc		  page=%p pfn=%lu order=%d migratetype=%d gfp_flags=%s
    e->virt_addr = 0; 
    // Event is a page allocation
    e->event_type = 0;
    // Page size order. 
    e->order = ctx->order;
     // Calculate total allocation size in bytes
    e->size = PAGE_SIZE << ctx->order; 

    e->pid = pid;
    bpf_get_current_comm(&e->comm, sizeof(e->comm));
    e->ts = bpf_ktime_get_ns();

    struct page_info info = {};
    info.alloc_ts = e->ts;
    bpf_map_update_elem(&page_lifecycle, &phys_addr, &info, BPF_ANY);

    bpf_ringbuf_submit(e, 0);
    return 0;
}


SEC("kprobe/handle_mm_fault")
int trace_page_fault(struct pt_regs *ctx)
{
    struct event *e;
    u64 virt_addr;
    u32 pid = bpf_get_current_pid_tgid() >> 32;

    u32 key = 0;
    u32 *target_pid_ptr;
    
    target_pid_ptr = bpf_map_lookup_elem(&target_pid, &key);
    if (!target_pid_ptr || (*target_pid_ptr != 0 && *target_pid_ptr != pid))
        return 0;

    e = bpf_ringbuf_reserve(&events, sizeof(*e), 0);
    if (!e)
        return 0;

    virt_addr = PT_REGS_PARM2(ctx);
    e->virt_addr = virt_addr;
    e->event_type = 1;
    e->pid = pid;
    e->phys_addr = 0;
    bpf_get_current_comm(&e->comm, sizeof(e->comm));
    e->ts = bpf_ktime_get_ns();

    bpf_ringbuf_submit(e, 0);
    return 0;
}

SEC("tp/kmem/mm_page_free")
int trace_page_free(struct trace_event_raw_mm_page_free *ctx)
{
    struct event *e;
    u64 phys_addr;
    u32 pid = bpf_get_current_pid_tgid() >> 32;

    u32 key = 0;
    u32 *target_pid_ptr;
    
    target_pid_ptr = bpf_map_lookup_elem(&target_pid, &key);
    if (!target_pid_ptr || (*target_pid_ptr != 0 && *target_pid_ptr != pid))
        return 0;

    phys_addr = ((u64)ctx->pfn) << PAGE_SHIFT;

    e = bpf_ringbuf_reserve(&events, sizeof(*e), 0);
    if (!e)
        return 0;

    e->phys_addr = phys_addr;
    e->event_type = 2;
    e->pid = pid;
    bpf_get_current_comm(&e->comm, sizeof(e->comm));
    e->ts = bpf_ktime_get_ns();

    bpf_map_delete_elem(&page_lifecycle, &phys_addr);

    bpf_ringbuf_submit(e, 0);
    return 0;
}
