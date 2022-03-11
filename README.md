# linux-playground

This is a playground to play with the Linux kernel, providing a easy to build and debug kernel inside a Docker container.

> The following steps are verified on Ubuntu 20.04, x86-64 machine.

## Prerequisites
The following are the packages and tools that are required to use this repo.
### Resources
We expect the machine to have atleast 5 GB of free disk space.

#### VScode
* Install VSCode by following the [official instructions](https://code.visualstudio.com/docs/setup/linux).
* Install Remote Development extension in VSCode (Identifier : ms-vscode-remote.vscode-remote-extensionpack) - Refer [instructions](https://code.visualstudio.com/learn/get-started/extensions) on how to install extensions.


#### Docker and utils
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose
```
##### Add your user to the docker group
 
- Create docker group : ```sudo groupadd docker```
- Add your user to the docker group : ```sudo usermod -aG docker $USER```
- Reboot or logout and login again

## Setup and Build Docker

> Note: all our steps are expected to work with VSCode. You may be able to use our image without VSCode but we do not currently support it.

Clone the playground repository: 

```bash
git clone https://github.com/purs3lab/linux-playground.git
```

The playground is integrated into the VSCode IDE. So start by opening the `linux-playground` folder in the VSCode IDE. 

```bash
code linux-playground
```

Once the playground is open, in VSCode you may see a message window at the bottom right of the editor window:


![opencontainer](./images/ReopenInCont.png)

Click on **Reopen in Container**

This command will build the relevant container image and bring up the workspace in the new environment. 

The VSCode will restart and you will see tthe following message at the bottom right of the window

![startingcontainer](./images/startingDev.png)

This may take a while. Once this process is done you should get your workspace now open inside the container. 
If you open a terminal from inside VS Code you should get a prompt from inside the container and everything.

At this point your VScode window should contain the linux kernel sources.

## Next steps

[Debugging the kernel](docs/DebugKernel.md)

[Modifying the kernel](docs/ModifyKernel.md)
