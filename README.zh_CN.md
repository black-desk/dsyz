<!--
SPDX-License-Identifier: GPL-3.0-or-later
SPDX-FileCopyrightText: Chen Linxuan <me@black-desk.cn>
-->

# dsyz - 为桌面内核运行Syzkaller

*[en](README.md)*

一个用于设置和运行 [syzkaller](https://github.com/google/syzkaller) 来模糊测试桌面 Linux 内核的工具。

## 概述

dsyz (Desktop SYZkaller) 是一个旨在简化 syzkaller 内核模糊测试设置和执行的实用工具。它自动化了以下过程：

1. 克隆并构建 syzkaller
2. 克隆并配置 Linux 内核，添加适当的模糊测试选项
3. 创建用于测试的虚拟机磁盘镜像
4. 使用正确的配置运行 syzkaller 管理器

## 安装

### 前提条件

- Bash shell
- Git
- Go 编译器（用于构建 syzkaller）
- QEMU
- 标准构建工具（make、gcc 等）

### 从源代码安装

```bash
git clone https://github.com/black-desk/dsyz.git
cd dsyz
sudo make install
```

## 使用方法

### 基本用法

```bash
dsyz
```

这将：

- 克隆并构建 syzkaller（如果尚未完成）
- 克隆并使用模糊测试配置构建 Linux 内核（如果尚未完成）
- 创建虚拟机磁盘镜像（如果尚未完成）
- 启动 syzkaller 管理器

### 传递参数给 syz-manager

你可以通过 `--` 向 syz-manager 传递额外参数，例如：

```bash
dsyz -- -debug -cover
```

所有 `--` 之后的参数都会被直接传递给 syz-manager。

例如，调试模式运行 syz-manager：

```bash
dsyz -- -debug
```

<!-- 注意：中英文文档在基本用例上的代码示例不同。中文文档中使用了中国的镜像服务，以便中文用户能够更快速地下载依赖库。 -->

```bash
env \
  DSYZ_SYZKALLER_REPO="https://gitcode.com/gh_mirrors/sy/syzkaller.git" \
  DSYZ_KERNEL_REPO="https://gitcode.com/gh_mirrors/li/linux.git" \
  dsyz
```

这将：

- 克隆并构建 syzkaller（如果尚未完成）
- 克隆并使用模糊测试配置构建 Linux 内核（如果尚未完成）
- 创建虚拟机磁盘镜像（如果尚未完成）
- 启动 syzkaller 管理器

```bash
env \
  DSYZ_SYZKALLER_REPO="https://gitcode.com/gh_mirrors/sy/syzkaller.git" \
  DSYZ_KERNEL_REPO="https://gitcode.com/deepin-community/kernel.git" \
  dsyz-deepin
```

这是一个包装脚本，用于配置 dsyz 使用 Deepin 内核仓库，并应用特定配置来模糊测试 Deepin 内核。

```bash
env \
  DSYZ_SYZKALLER_REPO="https://gitcode.com/gh_mirrors/sy/syzkaller.git" \
  dsyz-arch
```

这是一个包装脚本，用于使用 Arch Linux 内核仓库。它会自动获取最新的发布版本和 Arch Linux 仓库中的适当内核配置。

## 配置

dsyz 可以使用环境变量进行配置：

### 一般设置

- `DSYZ_WORKDIR` - 所有操作的工作目录（默认：当前目录）

### Syzkaller 编译设置

- `DSYZ_SYZKALLER_REPO` - syzkaller 的 Git 仓库 URL（默认：<https://github.com/google/syzkaller.git>）
- `DSYZ_REBUILD_SYZKALLER` - 设置为任何非空值以强制重新构建 syzkaller
- `DSYZ_UPDATE_SYZKALLER` - 设置为任何非空值以更新 syzkaller（隐含 DSYZ_REBUILD_SYZKALLER）

### 内核编译设置

- `DSYZ_KERNEL_REPO` - Linux 内核的 Git 仓库 URL（默认：<https://github.com/torvalds/linux.git>）
- `DSYZ_KERNEL_CONFIG_SCRIPT` - 可选的自定义内核配置脚本路径
- `DSYZ_KERNEL_CONFIG_FILE` - 可选的自定义内核配置文件路径
- `DSYZ_KERNEL_CONFIG` - 内核配置目标（默认：defconfig）
- `DSYZ_KERNEL_MAKE_JOBS` - 内核编译的并行作业数量（默认：nproc）
- `DSYZ_REBUILD_KERNEL` - 设置为任何非空值以强制重新构建内核
- `DSYZ_UPDATE_KERNEL` - 设置为任何非空值以更新内核源码（隐含 DSYZ_REBUILD_KERNEL）
- `DSYZ_RECREATE_IMAGE` - 设置为任何非空值以强制重新创建虚拟机磁盘镜像

#### 内核配置选项优先级

内核配置选项按以下优先级顺序处理：

1. `DSYZ_KERNEL_CONFIG_SCRIPT` - 如果提供，这个脚本将在内核目录内被执行以设置配置。它具有最高优先级，可以执行复杂的配置任务。

2. `DSYZ_KERNEL_CONFIG_FILE` - 如果没有提供脚本但设置了此变量，指定的文件将被复制为内核目录中的 `.config`。

3. `DSYZ_KERNEL_CONFIG` - 如果既没有提供脚本也没有提供文件，这个值将用作 `make <config-value>`（例如 `make defconfig`）的目标。默认值为 `defconfig`。

您可以参考包装脚本以获取示例：

- `dsyz-arch` 使用 `DSYZ_KERNEL_CONFIG_SCRIPT` 创建一个脚本，该脚本检出最新的 Arch Linux 内核版本并下载其配置。
- `dsyz-deepin` 使用 `DSYZ_KERNEL_CONFIG` 指定 Deepin 特定的 defconfig 目标。

### 虚拟机镜像设置

- `DSYZ_DISTRIBUTION` - 虚拟机镜像的 Linux 发行版（默认：bullseye）
- `DSYZ_IMAGE` - 存储虚拟机镜像的目录（默认：$DSYZ_WORKDIR/image）

### Syzkaller 设置

- `DSYZ_LISTEN` - HTTP 接口监听的 IP 地址（默认：127.0.0.1）
- `DSYZ_PORT` - HTTP 接口监听的端口（默认：56741）
- `DSYZ_TARGET` - syzkaller 的目标架构（默认：linux/amd64）
- `DSYZ_PROCS` - syzkaller 的并行进程数量（默认：8）
- `DSYZ_VM_COUNT` - 要运行的虚拟机数量（默认：4）
- `DSYZ_VM_CPU` - 每个虚拟机的 CPU 核心数（默认：2）
- `DSYZ_VM_MEMORY` - 每个虚拟机的内存大小（MB）（默认：2048）

### 工具路径

- `DSYZ_GIT` - git 可执行文件的路径（默认：git）
- `DSYZ_GO` - Go 可执行文件的路径（默认：go）
- `DSYZ_QEMU` - qemu 可执行文件的路径（默认：qemu-system-$(uname -m)）

## 示例

```bash
# 使用特定的工作目录
DSYZ_WORKDIR=/path/to/workdir dsyz

# 使用自定义内核仓库并强制重新构建
DSYZ_KERNEL_REPO=https://github.com/your/linux-fork.git DSYZ_REBUILD_KERNEL=1 dsyz

# 使用自定义内核配置文件
DSYZ_KERNEL_CONFIG_FILE=/path/to/your/kernel.config dsyz

# 强制重新构建 syzkaller 并指定自定义 Go 路径
DSYZ_REBUILD_SYZKALLER=1 DSYZ_GO=/usr/local/go/bin/go dsyz

# 运行更多虚拟机和更大内存
DSYZ_VM_COUNT=8 DSYZ_VM_MEMORY=4096 dsyz
```

## 许可证

本项目根据 GPL-3.0-or-later 许可证授权 - 详情请参阅 LICENSE 文件。
