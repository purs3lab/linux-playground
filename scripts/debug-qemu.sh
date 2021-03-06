#!/bin/bash

echo "Starting QEMU in Serial Mode - Use Ctrl-a + x to exit"
qemu-system-x86_64 -kernel /sources/linux/arch/x86_64/boot/bzImage -initrd /staging/initramfs-busybox-x86.cpio.gz -append "console=ttyS0 init=/init nokaslr" -nographic -s -S