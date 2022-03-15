.DEFAULT_GOAL := all

all: sample

sample:
	gcc -static sample.c -o sample

clean:
	rm -rf sample

copy-to-fs: all
	mkdir -p /staging/initramfs/fs/usermode
	cp sample /staging/initramfs/fs/usermode

