#!/bin/sh

ACCEL_ARGS=""
case "$(uname -m)" in
  aarch64|arm64)
    ACCEL_ARGS="-accel tcg"
    ;;
esac

exec qemu-system-x86_64 ${ACCEL_ARGS} \
  -smp 4 \
  -kernel /sources/linux/arch/x86/boot/bzImage \
  -initrd /staging/initramfs-busybox-x86.cpio.gz \
  -append "console=ttyS0 init=/init nokaslr" \
  -nographic
