<!--
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: Chen Linxuan <me@black-desk.cn>
-->

# dsyz - Run syzkaller for desktop linux kernel

*[zh_CN](README.zh_CN.md)*

A tool to setup and run [syzkaller](https://github.com/google/syzkaller) for fuzzing desktop Linux kernels.

## Overview

dsyz (Desktop SYZkaller) is a utility designed to simplify the setup and execution of syzkaller for kernel fuzzing. It automates the process of:

1. Cloning and building syzkaller
2. Cloning and configuring the Linux kernel with appropriate fuzzing options
3. Creating VM disk images for testing
4. Running the syzkaller manager with proper configuration

## Installation

### Prerequisites

- Bash shell
- Git
- Go compiler (for building syzkaller)
- QEMU
- Standard build tools (make, gcc, etc.)

### Install from source

```bash
git clone https://github.com/black-desk/dsyz.git
cd dsyz
sudo make install
```

## Usage

### Basic usage

```bash
dsyz
```

This will:

- Clone and build syzkaller (if not already done)
- Clone and build the Linux kernel with fuzzing configurations (if not already done)
- Create a VM disk image (if not already done)
- Start the syzkaller manager

### Pass arguments to syz-manager

You can pass additional arguments to syz-manager by using `--`:

```bash
dsyz -- -debug -cover
```

All arguments after `--` will be forwarded to syz-manager.

For example, to run syz-manager in debug mode:

```bash
dsyz -- -debug
```

### Wrapper scripts

```bash
dsyz-deepin
```

This is a wrapper script that configures dsyz to use the Deepin kernel repository and applies specific configurations for fuzzing the Deepin kernel.

```bash
dsyz-arch
```

This is a wrapper script for dsyz to use the Arch Linux kernel repository. It automatically fetches the latest release version and appropriate kernel configuration from the Arch Linux repositories.

## Configuration

dsyz can be configured using environment variables:

### General settings

- `DSYZ_WORKDIR` - Working directory for all operations (default: current directory)

### Syzkaller build settings

- `DSYZ_SYZKALLER_REPO` - Git repository URL for syzkaller (default: <https://github.com/google/syzkaller.git>)
- `DSYZ_REBUILD_SYZKALLER` - Set to any non-empty value to force rebuild syzkaller
- `DSYZ_UPDATE_SYZKALLER` - Set to any non-empty value to update syzkaller (implies DSYZ_REBUILD_SYZKALLER)

### Kernel build settings

- `DSYZ_KERNEL_REPO` - Git repository URL for Linux kernel (default: <https://github.com/torvalds/linux.git>)
- `DSYZ_KERNEL_CONFIG_SCRIPT` - Optional path to a custom kernel configuration script
- `DSYZ_KERNEL_CONFIG_FILE` - Optional path to a custom kernel configuration file
- `DSYZ_KERNEL_CONFIG` - Kernel config target (default: defconfig)
- `DSYZ_KERNEL_MAKE_JOBS` - Number of parallel jobs for kernel compilation (default: nproc)
- `DSYZ_REBUILD_KERNEL` - Set to any non-empty value to force rebuild the kernel
- `DSYZ_UPDATE_KERNEL` - Set to any non-empty value to update kernel source (implies DSYZ_REBUILD_KERNEL)
- `DSYZ_RECREATE_IMAGE` - Set to any non-empty value to force recreate VM disk image

#### Kernel Configuration Options Priority

The kernel configuration options are processed in the following priority order:

1. `DSYZ_KERNEL_CONFIG_SCRIPT` - If provided, this script will be sourced inside the kernel directory to set up configuration. It has the highest priority and can perform complex configuration tasks.

2. `DSYZ_KERNEL_CONFIG_FILE` - If no script is provided but this variable is set, the specified file will be copied as `.config` in the kernel directory.

3. `DSYZ_KERNEL_CONFIG` - If neither script nor file is provided, this value will be used as the target for `make <config-value>` (e.g., `make defconfig`). The default is `defconfig`.

You can refer to the wrapper scripts for examples:

- `dsyz-arch` uses `DSYZ_KERNEL_CONFIG_SCRIPT` to create a script that checks out the latest Arch Linux kernel version and downloads its configuration.
- `dsyz-deepin` uses `DSYZ_KERNEL_CONFIG` to specify the Deepin-specific defconfig target.

### VM image settings

- `DSYZ_DISTRIBUTION` - Linux distribution for the VM image (default: bullseye)
- `DSYZ_IMAGE` - Directory to store VM images (default: $DSYZ_WORKDIR/image)

### Syzkaller settings

- `DSYZ_LISTEN` - IP address to listen on for HTTP interface (default: 127.0.0.1)
- `DSYZ_PORT` - Port to listen on for HTTP interface (default: 56741)
- `DSYZ_TARGET` - Target architecture for syzkaller (default: linux/amd64)
- `DSYZ_PROCS` - Number of parallel processes for syzkaller (default: 8)
- `DSYZ_VM_COUNT` - Number of virtual machines to run (default: 4)
- `DSYZ_VM_CPU` - Number of CPU cores per virtual machine (default: 2)
- `DSYZ_VM_MEMORY` - Memory in MB per virtual machine (default: 2048)

### Tool paths

- `DSYZ_GIT` - Path to git executable (default: git)
- `DSYZ_GO` - Path to Go executable (default: go)
- `DSYZ_QEMU` - Path to qemu executable (default: qemu-system-$(uname -m))

## Example

```bash
# Use a specific working directory
DSYZ_WORKDIR=/path/to/workdir dsyz

# Use a custom kernel repository and force rebuild
DSYZ_KERNEL_REPO=https://github.com/your/linux-fork.git DSYZ_REBUILD_KERNEL=1 dsyz

# Use a custom kernel configuration file
DSYZ_KERNEL_CONFIG_FILE=/path/to/your/kernel.config dsyz

# Force rebuild syzkaller using a custom Go path
DSYZ_REBUILD_SYZKALLER=1 DSYZ_GO=/usr/local/go/bin/go dsyz

# Run with more virtual machines and memory
DSYZ_VM_COUNT=8 DSYZ_VM_MEMORY=4096 dsyz
```

## License

This project is licensed under GPL-3.0-or-later - see the LICENSE file for details.
