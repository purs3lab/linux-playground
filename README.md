# linux-playground

This is a playground to play with the Linux kernel, providing a easy to use build and debug environment inside a Docker container.

## Setup

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

Now, debugging the kernel is done using GDB (We use a modified version called GEF, which is a enhanced fork of GDB). To start the debugger you need to again open the command palette and type: 
``` Tasks: Run Task ```

Now from the prompt you need to select the `(debug) Start GDB` option. This should open up a new console where the debugger is running.
