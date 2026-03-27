IMAGE_NAME ?= benyoo/alpine
BASE_VERSION ?= 3.20
DATE_TAG ?= $(shell date +%Y%m%d)
VERSION ?= $(BASE_VERSION).$(DATE_TAG)

LOCAL_IMAGE := $(IMAGE_NAME):$(VERSION)
LATEST_IMAGE := $(IMAGE_NAME):latest

.PHONY: help dry-run build tag push release git-tag-create git-tag-push release-all

help:
	@echo "用法示例："
	@echo "  make build"
	@echo "  make dry-run"
	@echo "  make release"
	@echo "  make release-all"
	@echo ""
	@echo "变量："
	@echo "  IMAGE_NAME   (默认: benyoo/alpine)"
	@echo "  BASE_VERSION (默认: 3.20)"
	@echo "  DATE_TAG     (默认: 当天日期 YYYYMMDD)"
	@echo "  VERSION      (默认: BASE_VERSION.DATE_TAG)"

dry-run:
	@echo "[DRY-RUN] 将执行以下发布命令："
	@echo "docker build -t $(LOCAL_IMAGE) ."
	@echo "docker tag $(LOCAL_IMAGE) $(LATEST_IMAGE)"
	@echo "docker push $(LOCAL_IMAGE)"
	@echo "docker push $(LATEST_IMAGE)"
	@echo "git tag $(VERSION)   # 若不存在"
	@echo "git push origin $(VERSION)"
	@echo ""
	@echo "确认无误后执行：make release-all"

build:
	docker build -t $(LOCAL_IMAGE) .

tag: build
	docker tag $(LOCAL_IMAGE) $(LATEST_IMAGE)

push: tag
	docker push $(LOCAL_IMAGE)
	docker push $(LATEST_IMAGE)

release: push

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
