# Setup on a Virtual Machine/Host Machine

This setup has been tested on a **Ubuntu 20.04** machine. It is recommended to use a machine with the following specifications : 
    - **Ubuntu 20.04** LTS iso
    - 4GB of RAM
    - Atleast 20 GB of disk space
    - A network connection

## Download the Installation Script

The installation script is available on [Github](https://github.com/purs3lab/linux-playground/blob/playground-vm/non_vscode_setup.sh) and can be copied to your machine. It will automaically clone the repository and install all the necessary dependencies.

```bash
    $ wget https://raw.githubusercontent.com/purs3lab/linux-playground/playground-vm/non_vscode_setup.sh
    $ chmod +x non_vscode_setup.sh
    $ ./non_vscode_setup.sh
```

## Download VSCode

* Install VSCode by following the [official instructions](https://code.visualstudio.com/docs/setup/linux).

## Kernel Sources 

After the installation script is run (without errors), you should be able to see the following:
    - A folder named `playground` in your home directory (`$HOME/playground`)
    - The Linux kernel sources are available in the `$HOME/playground/sources/linux` folder
    - The setup scripts will be available in the `$HOME/playground/linux-playground/vmscripts` folder

## You can open the playground in VSCode now

```bash
    $ code $HOME/playground/sources/linux
```

Should open the linux kernel sources in VSCode, which can be used to debug and modify the kernel.

## Running the kernel

```bash
    $ cd $HOME/playground/linux-playground/vmscripts
    $ ./start-qemu.sh
```

    This should start a QEMU virtual machine with the kernel running.
