IMAGE_NAME ?= benyoo/alpine
BASE_VERSION ?= 3.24
DATE_TAG ?= $(shell date +%Y%m%d)
VERSION ?= $(BASE_VERSION).$(DATE_TAG)
SUPPORTED_BASE_VERSIONS ?= 3.20 3.21 3.22 3.23 3.24
PLATFORMS ?= linux/amd64,linux/arm64
BUILDX_BUILDER ?= alpine-multiarch

LOCAL_IMAGE := $(IMAGE_NAME):$(VERSION)
LATEST_IMAGE := $(IMAGE_NAME):latest

.PHONY: help dry-run check-version build buildx-create release git-tag-create git-tag-push release-all \
	supported-versions build-% release-%

help:
	@echo "用法示例："
	@echo "  make build"
	@echo "  make dry-run"
	@echo "  make release"
	@echo "  make release-all"
	@echo "  make release-3.24"
	@echo ""
	@echo "变量："
	@echo "  IMAGE_NAME   (默认: benyoo/alpine)"
	@echo "  BASE_VERSION (默认: 3.24)"
	@echo "  DATE_TAG     (默认: 当天日期 YYYYMMDD)"
	@echo "  VERSION      (默认: BASE_VERSION.DATE_TAG)"
	@echo "  PLATFORMS    (默认: linux/amd64,linux/arm64)"
	@echo "  SUPPORTED_BASE_VERSIONS (默认: $(SUPPORTED_BASE_VERSIONS))"

dry-run:
	@echo "[DRY-RUN] 将执行以下发布命令："
	@echo "docker build --build-arg ALPINE_VERSION=$(BASE_VERSION) -t $(LOCAL_IMAGE) ."
	@echo "docker buildx build --platform $(PLATFORMS) --build-arg ALPINE_VERSION=$(BASE_VERSION) -t $(LOCAL_IMAGE) -t $(LATEST_IMAGE) --push ."
	@echo "git tag $(VERSION)   # 若不存在"
	@echo "git push origin $(VERSION)"
	@echo ""
	@echo "确认无误后执行：make release-all"

supported-versions:
	@echo "$(SUPPORTED_BASE_VERSIONS)"

check-version:
	@case " $(SUPPORTED_BASE_VERSIONS) " in \
		*" $(BASE_VERSION) "*) ;; \
		*) echo "不支持 Alpine $(BASE_VERSION)，请先更新 SUPPORTED_BASE_VERSIONS"; exit 1 ;; \
	esac

build: check-version
	docker build --build-arg ALPINE_VERSION=$(BASE_VERSION) -t $(LOCAL_IMAGE) .

buildx-create:
	@if docker buildx inspect $(BUILDX_BUILDER) >/dev/null 2>&1; then \
		docker buildx use $(BUILDX_BUILDER); \
	else \
		docker buildx create --name $(BUILDX_BUILDER) --use; \
	fi
	@docker buildx inspect --bootstrap >/dev/null

release: check-version buildx-create
	docker buildx build --platform $(PLATFORMS) --build-arg ALPINE_VERSION=$(BASE_VERSION) -t $(LOCAL_IMAGE) -t $(LATEST_IMAGE) --push .

git-tag-create:
	@if [ -n "$$(git tag -l $(VERSION))" ]; then \
		echo "git tag $(VERSION) 已存在"; \
	else \
		git tag $(VERSION); \
		echo "git tag $(VERSION) 已创建"; \
	fi

git-tag-push: git-tag-create
	git push origin $(VERSION)

release-all: release git-tag-push

build-%:
	$(MAKE) build BASE_VERSION=$*

release-%:
	$(MAKE) release BASE_VERSION=$*
