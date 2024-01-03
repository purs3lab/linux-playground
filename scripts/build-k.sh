#!/bin/sh
# build linux

mkdir -p /staging/initramfs/fs

cd /sources/linux
make x86_64_defconfig
./scripts/config -d DEBUG_INFO_NONE -e DEBUG_INFO \
    -e DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT -d DEBUG_INFO_REDUCED \
    -e DEBUG_INFO_COMPRESSED_NONE -d DEBUG_INFO_COMPRESSED_ZLIB \
    -d DEBUG_INFO_SPLIT -e READABLE_ASM -e GDB_SCRIPTS
make -j4 bzImage
make scripts_gdb

# build busybox
cd /sources/busybox-1.32.1
make defconfig
LDFLAGS="--static" make -j4 install

