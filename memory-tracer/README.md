This tool works by using eBPF kernel hooks to instrument the kernel allocation and fault handlers. 

## Install Dependencies
NOTE: You would need to re run the first command if bpf tool throws kernel version errors to reinstall bpftool for the version of kernel you are running. 
```sh
sudo apt install linux-tools-common linux-tools-generic linux-tools-$(uname -r) 
sudo apt install libbpf-dev bpfcc-tools bpftrace build-essential clang llvm
```

## Running the tracer.

### In one terminal run.
```sh
sfx@friedrice:~/paging-peek$ ./build/test_alloc 
PID: 15703
Touching grass...
Testing malloc...
Testing mmap...
Touching grass completed. Going back into cave
```

### Parallely in another terminal run with the pid from above
```sh
sfx@friedrice:~/paging-peek$ sudo ./build/page_tracer -p 15703
Starting page tracer...
Filtering for PID 15703
TIME     EVENT   COMM             PID     VIRT ADDR          PHYS ADDR          SIZE       INFO
21:19:03 FAULT   test_alloc       15703   0x8fa46b8          0x0                           
21:19:03 ALLOC   test_alloc       15703   0x0                0x1bf526000        4.00KB     single
.
.
.
21:19:05 FREE    test_alloc       15703   0x0                0x1952aa000                   
```

Now you should be able to trace all the Fault and Alloc events happening in the kernel.
