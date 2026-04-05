# quark-core-builder

Based on [spruceUI/Cores-spruce](https://github.com/spruceUI/Cores-spruce)

This Docker image aims to build RetroArch cores for the [Quark](https://github.com/cobaltgit/Quark) system.

Cores are built using Steward Fu's Miyoo A30 toolchain (GCC 13.2.0, glibc 2.23, static glibcxx) and are optimised for the Cortex-A7 CPU.  
Compiler flags are specified in [`scripts/env.sh`](https://github.com/cobaltgit/quark-core-builder/blob/main/scripts/env.sh)

The build script uses libretro-super by default to fetch and build cores, however custom build scripts can be placed in the [`scripts/custom`](https://github.com/cobaltgit/quark-core-builder/tree/main/scripts/custom) directory

## Usage

```sh
$ docker run --rm -e CORES="space separated list of cores" -v /path/to/output:/output ghcr.io/cobaltgit/quark-core-builder
```

> [!WARNING]
> Some cores (particularly TIC-80) rely on host tools to build that may not be compiled natively...as such you may need to run the QEMU image beforehand:
> ```sh
> $ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
> ```
