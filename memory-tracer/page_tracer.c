// page_tracer.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <time.h>
#include <bpf/libbpf.h>
#include <bpf/bpf.h>
#include <stdint.h>
#include "page_tracer.skel.h"

static volatile bool running = true;
// Event types
enum event_type {
    EVENT_ALLOC = 0,
    EVENT_FAULT = 1,
    EVENT_FREE = 2,
};

struct event {
    __u64 ts;
    __u64 virt_addr;
    __u64 phys_addr;
    __u32 pid;
    char comm[16];
    __u32 event_type;
    __u32 order;
    __u64 size;
};

// Statistics tracking
struct stats {
    unsigned long allocations;
    unsigned long faults;
    unsigned long frees;
};

static struct stats global_stats = {};

static const char *event_type_str[] = {
    [EVENT_ALLOC] = "ALLOC",
    [EVENT_FAULT] = "FAULT",
    [EVENT_FREE] = "FREE",
};

static const char *get_size_str(__u64 size)
{
    static char buf[32];
    if (size >= (1ULL << 30)) {
        snprintf(buf, sizeof(buf), "%.2fGB", (float)size / (1ULL << 30));
    } else if (size >= (1ULL << 20)) {
        snprintf(buf, sizeof(buf), "%.2fMB", (float)size / (1ULL << 20));
    } else if (size >= (1ULL << 10)) {
        snprintf(buf, sizeof(buf), "%.2fKB", (float)size / (1ULL << 10));
    } else {
        snprintf(buf, sizeof(buf), "%lluB", size);
    }
    return buf;
}

static void print_header(void)
{
    printf("%-8s %-7s %-16s %-7s %-18s %-18s %-10s %s\n",
           "TIME", "EVENT", "COMM", "PID", "VIRT ADDR", "PHYS ADDR", "SIZE", "INFO");
}

static void sig_handler(int sig)
{
    running = false;
}

static int handle_event(void *ctx, void *data, size_t data_sz)
{
    const struct event *e = data;
    struct tm *tm;
    char ts[32];
    time_t t;
    
    // Convert from nanosecs to secs. 
    t = e->ts / 1000000000;
    tm = localtime(&t);
    strftime(ts, sizeof(ts), "%H:%M:%S", tm);


    switch (e->event_type) {
    case EVENT_ALLOC:
        global_stats.allocations++;
        break;
    case EVENT_FAULT:
        global_stats.faults++;
        break;
    case EVENT_FREE:
        global_stats.frees++;
        break;
    }

    // Print event details with size information
    printf("%-8s %-7s %-16s %-7d 0x%-16llx 0x%-16llx %-10s %s\n",
           ts,
           event_type_str[e->event_type],
           e->comm,
           e->pid,
           e->virt_addr,
           e->phys_addr,
           e->event_type == EVENT_ALLOC ? get_size_str(e->size) : "",
           e->event_type == EVENT_ALLOC ? 
               (e->order > 0 ? "compound" : "single") : "");

    return 0;
}


static void print_stats(void)
{
    printf("\nFinal Statistics:\n");
    printf("Total page allocations: %lu\n", global_stats.allocations);
    printf("Total page faults: %lu\n", global_stats.faults);
    printf("Total page frees: %lu\n", global_stats.frees);
}

static void usage(char *prog)
{
    fprintf(stderr,
            "Usage: %s [-p PID] [-v] [-h]\n"
            "  -p PID    Process ID to trace (default: trace all processes-extremely noisy)\n"
            "  -h        Show this help message\n",
            prog);
}

int main(int argc, char **argv)
{
    struct ring_buffer *rb = NULL;
    struct page_tracer_bpf *bpf_prog;
    int err;
    int opt;
    __u32 pid = 0;
    __u32 map_key = 0;
    bool p_set = false;

    // Parse command line arguments
    while ((opt = getopt(argc, argv, "p:h")) != -1) {
        switch (opt) {
        case 'p':
            pid = atoi(optarg);
            p_set = true;
            break;
        case 'h':
            usage(argv[0]);
            return 0;
        default:
            usage(argv[0]);
            return 1;
        }
    }

    if(p_set == false) {
        usage(argv[0]);
        return 0;
    }
    // This is so that we can dump stats on Ctrl-C
    signal(SIGINT, sig_handler);
    signal(SIGTERM, sig_handler);

    // Open and load BPF program
    bpf_prog = page_tracer_bpf__open_and_load();
    if (!bpf_prog) {
        fprintf(stderr, "Failed to open and load BPF skeleton\n");
        return 1;
    }

    // Update the target PID in the map
    err = bpf_map__update_elem(bpf_prog->maps.target_pid, &map_key, sizeof(map_key),
                              &pid, sizeof(pid), BPF_ANY);
    if (err) {
        fprintf(stderr, "Failed to update target PID map: %d\n", err);
        goto cleanup;
    }

    // Attach tracepoints and probes
    err = page_tracer_bpf__attach(bpf_prog);
    if (err) {
        fprintf(stderr, "Failed to attach BPF skeleton: %d\n", err);
        goto cleanup;
    }

    // Set up ring buffer
    rb = ring_buffer__new(bpf_map__fd(bpf_prog->maps.events), handle_event, NULL, NULL);
    if (!rb) {
        fprintf(stderr, "Failed to create ring buffer\n");
        err = -1;
        goto cleanup;
    }

    // Print header
    printf("Starting page tracer...\n");
    if (pid)
        printf("Filtering for PID %d\n", pid);
    
    print_header();

    // Main event loop
    while (running) {
        err = ring_buffer__poll(rb, 100 /* timeout, ms */);
        if (err == -EINTR) {
            err = 0;
            break;
        }
        if (err < 0) {
            fprintf(stderr, "Error polling ring buffer: %d\n", err);
            break;
        }
    }

    // Print final statistics
    print_stats();

cleanup:
    ring_buffer__free(rb);
    page_tracer_bpf__destroy(bpf_prog);
    return err < 0 ? 1 : 0;
}