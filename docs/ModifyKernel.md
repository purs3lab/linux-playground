# Rebuild the kernel
You can make changes to kernel sources in VSCode and play with the modified kernel.

On making changes to the kernel sources it's necessary to rebuild the kernel for the changes to take effect.

Building the kernel is setup as the default build task. You can use the build shortcut  <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>B</kbd> to automatically start the kernel build.

You can also start the build from the command palette by typing:
``` Tasks: Run Build Task ```

Once you rebuild the kernel, also [Rebuild the fs-image](../README.md#build-fs-image).

Now, you can restart and [debug kernel](./DebugKernel.md).
