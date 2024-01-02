FROM ubuntu:20.04

# Setup timezone for avoid tzdata hang
ENV TZ=America/New_York
ENV PYTHONIOENCODING=utf8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y \
    wget git qemu-system qemu-utils python3 python3-pip \
    gcc libelf-dev libssl-dev bc flex bison vim bzip2 cpio gdb curl \
    && rm -rf /var/lib/apt/lists/*

# Download kernel
RUN mkdir -p /sources
WORKDIR /sources
RUN git clone --depth=1 -b v6.6 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
RUN wget https://busybox.net/downloads/busybox-1.32.1.tar.bz2
RUN tar xvjf busybox-1.32.1.tar.bz2

# initial build, so as to speed up development
COPY ./scripts/build-k.sh /sources
RUN /sources/build-k.sh

# Qemu-KVM, needed for testing kernels inside a VM
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    iptables \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libvirt-daemon-system \
    qemu-kvm \
    virtinst \
    virt-viewer \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    packagekit-gtk3-module \
    && apt-get -y autoremove \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/*

# Setup GEF
RUN wget -O /root/.gdbinit-gef.py -q http://gef.blah.cat/py 
COPY ./scripts/.gdbinit_gef /sources/.gdbinit_gef
COPY ./scripts/.gdbinit_vscode /sources/.gdbinit_vscode
COPY ./scripts/.gdbinit_vscode /root/.gdbinit
ENV LC_CTYPE=C.UTF-8
ENV LANG=C.UTF-8

# Setup vscode stuff
WORKDIR /sources/linux
RUN git clone --depth=1 https://github.com/amezin/vscode-linux-kernel.git .vscode
RUN rm -rf .vscode/.git
RUN python3 .vscode/generate_compdb.py
COPY .vscode/tasks.json .vscode/tasks.json
COPY .vscode/launch.json .vscode/launch.json

# Build the FS
WORKDIR /sources
COPY ./scripts/build-fs.sh /sources
RUN /sources/build-fs.sh
