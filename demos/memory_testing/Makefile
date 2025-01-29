.DEFAULT_GOAL := all

all: memorytest

memorytest:
	gcc -static sample.c -o memorytest

clean:
	rm -rf memorytest

copy-to-fs: all
	mkdir -p /staging/initramfs/fs/usermode
	cp memorytest /staging/initramfs/fs/usermode

