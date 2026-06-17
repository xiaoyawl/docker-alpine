# benyoo/alpine

![Docker](https://img.shields.io/badge/docker-benyoo%2Falpine-blue)
![Alpine](https://img.shields.io/badge/Alpine-3.24-0D597F)
![Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-brightgreen)

`benyoo/alpine` 是一个面向调试、CI 辅助和轻量运维场景的 Alpine 工具箱镜像。它基于 Alpine 3.24，预置 bash 登录环境、常用网络/文件/检索工具、交互式别名和 root 用户 vim 配置，适合在服务器上快速拉起一个干净、轻量、顺手的临时容器。

## 核心特性

| 能力 | 说明 |
|---|---|
| Alpine 3.24 | 当前默认基础版本为 `3.24` |
| 多架构 | 支持 `linux/amd64` 和 `linux/arm64` |
| bash 登录环境 | 默认进入 `bash -l`，root shell 已切到 bash |
| 常用工具 | 内置 `bash`、`curl`、`vim`、`tree`、`ripgrep`、`iproute2` 等 |
| 交互优化 | 预置 `ls`、`vi`、`tree`、`rg` 常用别名 |
| 规范 tag | 版本 tag 使用 `3.24.YYYYMMDD`，同时发布 `latest` |

## 支持架构

| 架构 | 典型环境 |
|---|---|
| `linux/amd64` | Intel/AMD 服务器、常见云主机、x86_64 虚拟机 |
| `linux/arm64` | ARM 服务器、Apple Silicon、arm64 云主机 |

## 快速开始

拉取最新版本：

```bash
docker pull benyoo/alpine:latest
```

启动临时交互容器：

```bash
docker run --rm -it benyoo/alpine:latest
```

使用指定版本：

```bash
docker run --rm -it benyoo/alpine:3.24.<YYYYMMDD>
```

进入容器后默认工作目录为 `/root`。

## 常用运行方式

临时网络排查：

```bash
docker run --rm -it \
  --name alpine-toolbox \
  benyoo/alpine:latest
```

挂载当前目录做文件处理：

```bash
docker run --rm -it \
  -v "$PWD:/work" \
  -w /work \
  benyoo/alpine:latest
```

使用 host 网络排查本机服务：

```bash
docker run --rm -it \
  --network host \
  benyoo/alpine:latest
```

执行一次性命令：

```bash
docker run --rm \
  benyoo/alpine:latest \
  bash -lc 'cat /etc/alpine-release && rg --version | head -1'
```

## Docker Compose 示例

```yaml
services:
  alpine-toolbox:
    image: benyoo/alpine:latest
    container_name: alpine-toolbox
    restart: unless-stopped
    tty: true
    stdin_open: true
    working_dir: /root
    command: ["bash", "-l"]
```

启动：

```bash
docker compose up -d
docker exec -it alpine-toolbox bash -l
```

停止并删除：

```bash
docker compose down
```

## 预装软件

| 分类 | 软件 |
|---|---|
| Shell | `bash`、`bash-completion` |
| 网络/证书 | `ca-certificates`、`openssl`、`curl`、`iproute2` |
| 文件/归档 | `tar`、`tree` |
| 编辑/检索 | `vim`、`ripgrep` |

## 交互别名

| 别名 | 实际命令 |
|---|---|
| `ls` | `ls --color=auto` |
| `vi` | `vim` |
| `tree` | `tree -C -lha -D --du --timefmt '%F %T'` |
| `rg` | `rg --smart-case` |

## Tag 规则

| Tag | 说明 |
|---|---|
| `latest` | 最近一次发布的多架构镜像 |
| `3.24.YYYYMMDD` | Alpine 基础版本 + 发布日期 |

示例：

```text
benyoo/alpine:latest
benyoo/alpine:3.24.<YYYYMMDD>
```

## 验证镜像

查看 Alpine 版本：

```bash
docker run --rm benyoo/alpine:latest cat /etc/alpine-release
```

查看工具版本：

```bash
docker run --rm \
  benyoo/alpine:latest \
  bash -lc 'vim --version | head -1 && tree --version && rg --version | head -1'
```

验证多架构 manifest：

```bash
docker buildx imagetools inspect benyoo/alpine:latest
```

## 从源码构建

本地单架构测试：

```bash
docker build \
  --build-arg ALPINE_VERSION=3.24 \
  -t benyoo/alpine:local .
```

多架构发布使用 Docker Buildx：

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg ALPINE_VERSION=3.24 \
  -t benyoo/alpine:3.24.<YYYYMMDD> \
  -t benyoo/alpine:latest \
  --push \
  .
```

项目仓库内已经提供 Makefile，维护者可以直接使用：

```bash
make dry-run
make release
```

## 适用场景

| 场景 | 用法 |
|---|---|
| 临时排查 | 拉起容器后使用 `curl`、`ip`、`rg`、`tree` 快速检查 |
| CI 辅助 | 作为轻量 shell 工具环境执行脚本 |
| 文件处理 | 挂载目录后用 `vim`、`rg`、`tree` 检索和整理 |
| 多平台运行 | 同一个 tag 自动适配 amd64 / arm64 |

## 注意事项

- 示例命令默认以 root 环境执行。
- `latest` 表示最近一次发布，生产场景建议固定到日期 tag。
- 本镜像定位为轻量工具箱，不包含完整发行版服务管理栈。
- 如果需要发布新镜像，请先执行 `make dry-run` 确认 tag、平台和推送目标。
