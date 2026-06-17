# Docker Alpine 镜像

[![Docker](https://img.shields.io/badge/docker-benyoo%2Falpine-blue)](https://hub.docker.com/r/benyoo/alpine)
[![Alpine](https://img.shields.io/badge/Alpine-3.24-0D597F)](https://www.alpinelinux.org/)
[![Arch](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-brightgreen)](#-多架构支持)

基于 Alpine 3.24 构建的轻量级开发容器镜像，预置常用终端工具、bash 登录环境和交互式别名，适合临时调试、CI 辅助和轻量运维工具箱。

---

## 📚 文档导航

| 文档 | 说明 |
|------|------|
| [DockerHub 展示文档](dockerhub-repository-overview.tmp.md) | 可直接复制到 DockerHub Repository Overview 的中文展示文案 |
| [项目文档导航](docs/README.md) | 按使用、构建、发布、验证、升级等任务查找详细文档 |

---

## ✨ 特性

### 🚀 核心能力

| 能力 | 说明 |
|------|------|
| 🧱 Alpine 3.24 | 默认基础版本已升级到 `3.24` |
| 🌍 多架构 | 支持 `linux/amd64`、`linux/arm64` |
| 🏷️ 规范命名 | 镜像 tag 固定为 `${BASE_VERSION}.${YYYYMMDD}` |
| 🧰 常用工具 | 内置 `bash`、`curl`、`vim`、`tree`、`ripgrep` 等 |
| 🔁 易升级 | 版本集中在 `Makefile` 变量中维护 |

### 📦 预装软件

| 分类 | 软件 |
|------|------|
| Shell | `bash`、`bash-completion` |
| 网络/证书 | `ca-certificates`、`openssl`、`curl`、`iproute2` |
| 文件/归档 | `tar`、`tree` |
| 编辑/检索 | `vim`、`ripgrep` |

### 🛠️ 交互优化

| 别名 | 实际命令 |
|------|----------|
| `ls` | `ls --color=auto` |
| `vi` | `vim` |
| `tree` | `tree -C -lha -D --du --timefmt '%F %T'` |
| `rg` | `rg --smart-case` |

---

## 🚀 快速开始

### 使用预构建镜像

```bash
docker run --rm -it benyoo/alpine:3.24.20260612
```

如需始终使用最新发布版本：

```bash
docker run --rm -it benyoo/alpine:latest
```

### 本地单架构构建

```bash
make build
```

等价于：

```bash
docker build \
  --build-arg ALPINE_VERSION=3.24 \
  -t benyoo/alpine:3.24.$(date +%Y%m%d) .
```

### 多架构构建并推送

```bash
make release
```

默认推送平台：

```text
linux/amd64,linux/arm64
```

如需临时调整平台：

```bash
make release PLATFORMS=linux/arm64
```

---

## 🏷️ 镜像命名规则

项目镜像命名保持统一格式：

```text
benyoo/alpine:${BASE_VERSION}.${DATE_TAG}
benyoo/alpine:latest
```

| 变量 | 默认值 | 示例 |
|------|--------|------|
| `IMAGE_NAME` | `benyoo/alpine` | `benyoo/alpine` |
| `BASE_VERSION` | `3.24` | `3.24` |
| `DATE_TAG` | 当天日期 `YYYYMMDD` | `20260612` |
| `VERSION` | `${BASE_VERSION}.${DATE_TAG}` | `3.24.20260612` |

示例发布结果：

| Tag | 含义 |
|-----|------|
| `benyoo/alpine:3.24.20260612` | 指定 Alpine 基础版本 + 发布日期 |
| `benyoo/alpine:latest` | 最近一次发布的镜像 |

---

## 🏗️ 构建发布流程

```mermaid
flowchart LR
  A[更新 BASE_VERSION] --> B[make dry-run]
  B --> C[make build]
  C --> D[make release]
  D --> E[make git-tag-push]
```

### 常用命令

| 命令 | 说明 | 是否推送镜像 |
|------|------|--------------|
| `make help` | 查看可用命令和变量 | 否 |
| `make dry-run` | 预览发布命令 | 否 |
| `make build` | 本地单架构构建 | 否 |
| `make release` | buildx 多架构构建并推送 | 是 |
| `make release-all` | 推送镜像并同步 Git tag | 是 |
| `make build-3.24` | 快速构建指定 Alpine 版本 | 否 |
| `make release-3.24` | 快速发布指定 Alpine 版本 | 是 |

### 发布前预览

```bash
make dry-run
```

输出会展示完整的镜像 tag、平台列表和 Git tag。

### 标准发布

```bash
make release-all
```

该命令会执行：

1. 检查 `BASE_VERSION` 是否在 `SUPPORTED_BASE_VERSIONS` 中
2. 创建或复用 buildx builder
3. 推送多架构镜像 manifest
4. 创建并推送同名 Git tag

---

## 🌍 多架构支持

| 平台 | 适用场景 |
|------|----------|
| `linux/amd64` | Intel/AMD 服务器、常见云主机 |
| `linux/arm64` | Apple Silicon、ARM 服务器 |

多架构发布命令：

```bash
make release PLATFORMS=linux/amd64,linux/arm64
```

Docker buildx 会为同一个 tag 生成多平台 manifest，用户拉取镜像时会自动匹配当前机器架构。

---

## 🔁 版本升级指南

升级到下一个 Alpine 版本时，只需要集中修改两处：

| 文件 | 字段 | 示例 |
|------|------|------|
| `Dockerfile` | `ARG ALPINE_VERSION` | `ARG ALPINE_VERSION=3.25` |
| `Makefile` | `BASE_VERSION` / `SUPPORTED_BASE_VERSIONS` | `BASE_VERSION ?= 3.25` |

推荐流程：

```bash
make dry-run BASE_VERSION=3.25
make build BASE_VERSION=3.25
make release-all BASE_VERSION=3.25
```

如果希望保留快捷目标 `make build-3.25` / `make release-3.25`，把 `3.25` 加入 `SUPPORTED_BASE_VERSIONS` 即可。

---

## 🧪 验证

### 查看 Alpine 版本

```bash
docker run --rm benyoo/alpine:3.24.20260612 cat /etc/alpine-release
```

### 验证 bash 登录环境

```bash
docker run --rm -it benyoo/alpine:3.24.20260612
```

### 验证工具是否可用

```bash
docker run --rm benyoo/alpine:3.24.20260612 bash -lc 'vim --version | head -1 && tree --version && rg --version | head -1'
```

---

## 📂 项目结构

```text
.
├── Dockerfile   # 镜像定义，维护 Alpine 默认版本与预装工具
├── Makefile     # 构建、发布、多架构和 Git tag 自动化
└── README.md    # 使用、发布与升级说明
```

---

## ⚡ 快速链接

| 链接 | 说明 |
|------|------|
| [Alpine Linux](https://www.alpinelinux.org/) | Alpine 官方网站 |
| [Docker buildx](https://docs.docker.com/buildx/working-with-buildx/) | Docker 多架构构建 |
| [Docker Hub](https://hub.docker.com/r/benyoo/alpine) | 镜像仓库 |

---

## 👤 作者

**LookBack**

- Email: mondeolove@gmail.com
- Website: https://www.dwhd.org
