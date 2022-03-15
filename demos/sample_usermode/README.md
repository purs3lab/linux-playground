# Simple "hello world" module

Connect to the AOS container, then:

```bash
cd /demos/sample_usermode
make all               # to build the application
make copy-to-fs        # prepare the application to be used for the next `build-fs.sh`
/scripts/build-fs.sh   # build the file system
```

Once in the QEMU env:

```
cd usermode
./sample
```
