#!/bin/sh

mkdir -p $HOME/playground/staging/initramfs/fs

cd $HOME/playground/staging/initramfs/fs
mkdir -pv bin sbin etc proc sys usr/bin usr/sbin
cp -av $HOME/playground/sources/busybox-1.32.1/_install/* .
cp $HOME/playground/linux-playground/scripts/init .
find . -print0 | cpio --null -ov --format=newc | gzip -9 > $HOME/playground/staging/initramfs-busybox-x86.cpio.gz
cd $HOME/playground/staging
