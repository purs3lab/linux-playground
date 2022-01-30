FROM ubuntu:20.04

# Setup timezone for avoid tzdata hang
ENV TZ=America/New_York
ENV PYTHONIOENCODING=utf8
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get install -y wget git qemu-system qemu-utils python3 python3-pip \
        gcc libelf-dev libssl-dev bc flex bison vim bzip2 cpio gdb curl

# Download kernel
RUN mkdir -p /sources
WORKDIR /sources
RUN git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
RUN wget https://busybox.net/downloads/busybox-1.32.1.tar.bz2
RUN tar xvjf busybox-1.32.1.tar.bz2

# Setup GEF
RUN wget -O /root/.gdbinit-gef.py -q http://gef.blah.cat/py 
RUN echo -e "source /root/.gdbinit-gef.py\ntarget remote:1234" >> /root/.gdbinit

# initial build, so as to speed up development
COPY ./scripts/build-k.sh /sources
RUN /sources/build-k.sh

# Qemu-KVM, needed for testing kernels inside a VM
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get -y install \
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

# Setup vscode stuff
WORKDIR /sources/linux
RUN git clone https://github.com/amezin/vscode-linux-kernel.git .vscode
RUN python3 .vscode/generate_compdb.py

WORKDIR /scripts
