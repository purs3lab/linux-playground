#!/bin/bash

echo "Starting QEMU in Serial Mode - Use Ctrl-a + x to exit"
qemu-system-x86_64 -smp 4 -kernel $HOME/playground/sources/linux/arch/x86_64/boot/bzImage -initrd $HOME/playground/staging/initramfs-busybox-x86.cpio.gz -append "console=ttyS0 init=/init nokaslr" -nographic
