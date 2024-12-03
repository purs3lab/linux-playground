#!/bin/bash
set -x

ARCH=$(uname -m | sed 's/x86_64/x86/' | sed 's/aarch64/arm64/')

mkdir -p build

bpftool btf dump file /sys/kernel/btf/vmlinux format c > build/vmlinux.h

clang -g -O2 -target bpf \
    -D__TARGET_ARCH_${ARCH} \
    -c page_tracer.bpf.c \
    -o build/page_tracer.bpf.o

llvm-strip -g build/page_tracer.bpf.o

bpftool gen skeleton build/page_tracer.bpf.o > page_tracer.skel.h

gcc -g -Wall -I. -Ibuild page_tracer.c -o build/page_tracer -lelf -lbpf

gcc -g -Wall -I. -Ibuild test_alloc.c -o build/test_alloc