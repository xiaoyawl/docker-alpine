# Docker Alpine 文档导航

这里是 `benyoo/alpine` 项目的文档入口，用来区分 DockerHub 展示文案、项目维护文档和构建发布操作。

## 快速入口

| 文档 | 适用场景 |
|---|---|
| [项目详细说明](../README.md) | 查看镜像能力、快速开始、命名规则、构建发布、升级和验证方式 |
| [DockerHub 展示文档](../dockerhub-repository-overview.tmp.md) | 复制到 DockerHub Repository Overview 的中文展示文案 |
| [Dockerfile](../Dockerfile) | 查看基础镜像版本、预装软件、bash 登录环境、别名和 vimrc 配置 |
| [Makefile](../Makefile) | 查看本地构建、多架构发布、tag 规则和快捷目标 |

## 按任务查找

| 我要做什么 | 看哪里 |
|---|---|
| 直接运行镜像 | [项目详细说明 - 快速开始](../README.md#-快速开始) |
| 查看内置工具 | [项目详细说明 - 预装软件](../README.md#-预装软件) |
| 了解镜像 tag 规则 | [项目详细说明 - 镜像命名规则](../README.md#-镜像命名规则) |
| 执行构建或发布 | [项目详细说明 - 构建发布流程](../README.md#-构建发布流程) |
| 验证镜像可用性 | [项目详细说明 - 验证](../README.md#-验证) |
| 升级 Alpine 基础版本 | [项目详细说明 - 版本升级指南](../README.md#-版本升级指南) |
| 更新 DockerHub 页面 | [DockerHub 展示文档](../dockerhub-repository-overview.tmp.md) |

## 维护者流程

发布前建议按以下顺序检查：

```bash
make dry-run
make build
make release
```

如果需要同步 Git tag：

```bash
make release-all
```

默认多架构平台：

```text
linux/amd64,linux/arm64
```

## 文档维护约定

| 文件 | 维护重点 |
|---|---|
| `README.md` | 项目内详细说明，保留构建、发布、升级、验证细节 |
| `dockerhub-repository-overview.tmp.md` | DockerHub 粘贴版，强调镜像用途、运行示例和用户视角 |
| `docs/README.md` | 文档导航，不承载过多正文，主要负责链接 |

更新 DockerHub 页面时，优先复制 `dockerhub-repository-overview.tmp.md` 的完整内容。
