# docker-alpine

基于 `alpine:3.20` 的常用开发容器镜像，内置常见工具与交互体验优化（`bash`、`vim`、`tree`、`ripgrep` 等）。

## 功能说明

- 基础镜像：`alpine:3.20`
- 默认进入：`bash` 登录环境
- 预装工具：
  - `bash`、`bash-completion`
  - `curl`、`ca-certificates`、`openssl`、`tar`
  - `iproute2`、`vim`、`tree`、`ripgrep`
- 预置别名：
  - `ls` -> `ls --color=auto`
  - `vi` -> `vim`
  - `tree` -> `tree -C -lha -D --du --timefmt '%F %T'`
  - `rg` -> `rg --smart-case`

## 快速开始

在项目根目录执行：

```bash
docker build -t benyoo/alpine:3.20.$(date +%Y%m%d) .
```

启动容器并进入交互环境：

```bash
docker run --rm -it benyoo/alpine:3.20.$(date +%Y%m%d)
```

## 常用示例

### 运行 tree

```bash
tree
```

### 运行 ripgrep

```bash
rg "keyword" .
```

### 查看别名是否生效

```bash
alias | rg "ls|vi|tree|rg"
```

## 发布流程（build -> tag -> push）

以下以发布 `benyoo/alpine:3.20.<当天日期>` 为例：

### 1) 构建镜像（build）

```bash
docker build -t benyoo/alpine:3.20.$(date +%Y%m%d) .
```

### 2) 添加镜像标签（tag）

将版本标签同时打上 `latest`：

```bash
docker tag benyoo/alpine:3.20.$(date +%Y%m%d) benyoo/alpine:latest
```

### 3) 推送镜像（push）

```bash
docker login
docker push benyoo/alpine:3.20.$(date +%Y%m%d)
docker push benyoo/alpine:latest
```

### 4) （可选）同步 Git 标签

如需同步 Git tag（建议与镜像版本一致）：

```bash
git tag 3.20.$(date +%Y%m%d)
git push origin 3.20.$(date +%Y%m%d)
```

## 自动化发布（Makefile）

项目已提供 `Makefile`，可用一条命令执行标准发布流程。

### 常用命令

仅构建本地镜像：

```bash
make build
```

仅预览发布命令（不实际执行）：

```bash
make dry-run
```

构建 + 打远程标签 + 推送镜像：

```bash
make release
```

构建 + 推送镜像 + 推送 Git tag：

```bash
make release-all
```

### 可选变量

- `IMAGE_NAME`：镜像名，默认 `benyoo/alpine`
- `BASE_VERSION`：基础版本号，默认 `3.20`
- `DATE_TAG`：日期后缀，默认当天日期（`YYYYMMDD`）
- `VERSION`：最终版本号，默认 `BASE_VERSION.DATE_TAG`

例如发布 `3.21.<当天日期>`：

```bash
make release BASE_VERSION=3.21
```

## Tag 说明

默认版本命名规则：`3.20.<当天日期>`，例如 `3.20.20260327`。

如需推送到远程仓库，请手动执行：

```bash
git push origin 3.20.20260327
```

## 文件说明

- `Dockerfile`：镜像构建定义
- `README.md`：使用说明文档
- `Makefile`：自动化构建与发布入口
