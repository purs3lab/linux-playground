#!/bin/bash

read -p "Are you sure? (Please use this only if your extensions fail to work!) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Setting up the environment...."

    # set environment variables
    echo "export LC_CTYPE=C.UTF-8" >> $HOME/.bashrc
    echo "export LANG=C.UTF-8" >> $HOME/.bashrc
    echo "export TZ=America/New_York" >> $HOME/.bashrc
    echo "export PYTHONIOENCODING=UTF-8" >> $HOME/.bashrc

    # Install dependencies
    sudo apt-get update
    sudo apt-get install -y wget git qemu-system qemu-utils python3 python3-pip \
        gcc libelf-dev libssl-dev bc flex bison vim bzip2 cpio gdb curl

    mkdir -p $HOME/playground
    cd $HOME/playground
    git clone https://github.com/purs3lab/linux-playground.git
    cd linux-playground
    git checkout playground-vm
    cd $HOME/playground

    mkdir -p $HOME/playground/sources
    cd $HOME/playground/sources
    git clone --depth=1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
    wget https://busybox.net/downloads/busybox-1.32.1.tar.bz2
    tar xvjf busybox-1.32.1.tar.bz2

    # Qemu-KVM, needed for testing kernels inside a VM
    export DEBIAN_FRONTEND=noninteractive &&\
    sudo apt-get -y install \
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
    && sudo apt-get -y autoremove \
    && sudo apt-get -y clean \
    && sudo rm -rf /var/lib/apt/lists/*

    # build kernel
    $HOME/playground/linux-playground/vmscripts/build-k.sh
    
    # Gdbinit
    cp $HOME/playground/linux-playground/scripts/.gdbinit_vscode .gdbinit
    
    cd $HOME/playground/sources/linux
    git clone --depth=1 https://github.com/amezin/vscode-linux-kernel.git .vscode
    rm -rf .vscode/.git
    python3 .vscode/generate_compdb.py
    cp $HOME/playground/linux-playground/vmscripts/launch.json $HOME/playground/sources/linux/.vscode/launch.json
    
    # Run the new build FS
    $HOME/playground/linux-playground/vmscripts/build-fs.sh


    echo "Done! Now start the QEMU Emulator"
fi
