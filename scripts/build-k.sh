#!/bin/sh
# build linux

mkdir -p /staging/initramfs/fs

cd /sources/linux
make x86_64_defconfig
./scripts/config -e DEBUG_INFO -e READABLE_ASM -e GDB_SCRIPTS
make -j4 bzImage


# build busybox
cd /sources/busybox-1.32.1
make defconfig
LDFLAGS="--static" make -j4 install

