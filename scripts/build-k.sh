#!/bin/sh
# build linux

ARCH_ARGS=""
CROSS_COMPILE_ARGS=""

case "$(uname -m)" in
  aarch64|arm64)
    ARCH_ARGS="ARCH=x86_64"
    CROSS_COMPILE_ARGS="CROSS_COMPILE=x86_64-linux-gnu-"
    ;;
esac

mkdir -p /staging/initramfs/fs

cd /sources/linux
make ${ARCH_ARGS} ${CROSS_COMPILE_ARGS} x86_64_defconfig
./scripts/config -d DEBUG_INFO_NONE -e DEBUG_INFO \
    -e DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT -d DEBUG_INFO_REDUCED \
    -e DEBUG_INFO_COMPRESSED_NONE -d DEBUG_INFO_COMPRESSED_ZLIB \
    -d DEBUG_INFO_SPLIT -e READABLE_ASM -e GDB_SCRIPTS
make ${ARCH_ARGS} ${CROSS_COMPILE_ARGS} -j4 bzImage
make ${ARCH_ARGS} ${CROSS_COMPILE_ARGS} scripts_gdb

# build busybox
cd /sources/busybox-1.32.1
make ${ARCH_ARGS} ${CROSS_COMPILE_ARGS} defconfig
LDFLAGS="--static" make ${ARCH_ARGS} ${CROSS_COMPILE_ARGS} -j4 install
