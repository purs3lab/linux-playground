# Start QEMU with the first serial (ttyS0) mapped to stdio, and the second one mapped to port 6000
qemu-system-x86_64 -smp 4 -kernel /sources/linux/arch/x86_64/boot/bzImage -initrd /staging/initramfs-busybox-x86.cpio.gz -append "console=ttyS0 init=/init" -nographic./ 

