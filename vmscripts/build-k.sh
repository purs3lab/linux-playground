#!/bin/sh
# build linux

mkdir -p $HOME/playground/staging/initramfs/fs

cd $HOME/playground/sources/linux
make x86_64_defconfig
./scripts/config -e DEBUG_INFO -e READABLE_ASM -e GDB_SCRIPTS
make -j4 bzImage
make scripts_gdb

# build busybox
cd $HOME/playground/sources/busybox-1.32.1
make defconfig
LDFLAGS="--static" make -j4 install
