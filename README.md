# linux-playground

This is a playground to play with the Linux kernel, providing a easy to use build and debug environment inside a Docker container.

## Prerequisites

- System with an intel chip (Sorry ARM folks, but I don't have a ARM chip to test on)
- Must have Visual Studio code installed, with the Remote Development extension installed (Identifier : ms-vscode-remote.vscode-remote-extensionpack)
- Must have Docker installed and docker deamon running
- Docker-compose must be installed

### Add your user to the docker group
 
- Create docker group : ```sudo groupadd docker```
- Add your user to the docker group : ```sudo usermod -aG docker $USER```
- Reboot/logout and login again

## Setup - VS Code Way

Clone the playground repository: 

```bash
git clone https://github.com/purs3lab/linux-playground.git
```

The playground is integrated into the VSCode IDE. So start by opening the `linux-playground` folder in the VSCode IDE. Once the playground is open, in VSCode - you should be able to start the playground by opening the command palette. Command Palette is mapped by default to <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> 

Now you need to type into the command palette the following command: 

``` Remote-Containers: Rebuild and Reopen in Container ```

Once started, this command will build the relevant container image and bring up the workspace in the new environment. This may take a while. Once this process is done you should get your workspace now open inside the container. If you open a terminal from inside VS Code you should get a prompt from inside the container and everything.

At this point your VScode window should contain the linux kernel sources.

## Rebuild the kernel

Building the kernel is setup as the default build task. You can use the build shortcut  kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd> to automatically start the kernel build.

You can also start the build from the command palette by typing:
``` Tasks: Run Build Task ```

## Debug the kernel

To debug the kernel, you need to first start the kernel in QEMU on debug mode. This is done by bringing up the command palette and typing:
``` Tasks: Run Task ```

Which should give you a prompt with multiple options. Select the `(debug) Start Kernel in QEMU` option. This should open up a new console where the Kernel is running.
If there are no errors, and you see no output on the console that means that kernel is waiting for the GDB stub to be connected.

> **Note** : You need to start the kernel first always before connecting to it with GDB. 

Now, debugging the kernel is done using GDB (We use a modified version called GEF, which is a enhanced fork of GDB). To start the debugger you need to again open the command palette and type: 
``` Tasks: Run Task ```

Now from the prompt you need to select the `(debug) Start GDB` option. This should open up a new console where the debugger is running.

> **Note** : Only one instance of a kernel can be debugged at a time. If your kernel is already being debugged, you will get an error.
> Also, Both the kernel and the debugger need to be restarted to start a new debugging session.

## Debugging the kernel

All the symbols and all the helper functions for the Linux Kernel are already loaded and available to you when you start the debugger. You can test out debugging by seeing if you can break at the `start_kernel` function.
Note that the kernel is not running when you connect to it, so you need to manually start the kernel with the `c` or `continue` command in GDB.

> **Note** : When the kernel is running you will not get access to debug commands. You need to manually sent and interrupt to the kernel from GDB to stop it and get access to debug commands.
> Interrupts can be sent by pressing - <kbd>Ctrl</kbd> + <kbd>C</kbd>

## Setup - Non VSCode Way

Clone the playground repository: 

```bash
git clone https://github.com/purs3lab/linux-playground.git
```

You can start the container by running the following commands:

```bash
cd linux-playground
docker-compose up -d
```

You can connect to the container now from multiple terminals by running:

```bash
docker exec -it playground /bin/bash
```
