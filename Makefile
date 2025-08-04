GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)

# Git information
GIT_VERSION ?= $(shell git describe --tags --always)
GIT_COMMIT_HASH ?= $(shell git rev-parse HEAD)
GIT_TREESTATE = "clean"
GIT_DIFF = $(shell git diff --quiet >/dev/null 2>&1; if [ $$? -eq 1 ]; then echo "1"; fi)
ifeq ($(GIT_DIFF), 1)
    GIT_TREESTATE = "dirty"
endif
BUILDDATE = $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

LDFLAGS = "-X github.com/gocrane/crane/pkg/version.gitTag=$(GIT_VERSION) \
                      -X github.com/gocrane/crane/pkg/version.gitCommit=$(GIT_COMMIT_HASH) \
                      -X github.com/gocrane/crane/pkg/version.gitTreeState=$(GIT_TREESTATE) \
                      -X github.com/gocrane/crane/pkg/version.buildDate=$(BUILDDATE)"

# Image URL to use all building/pushing image targets
# 基础变量定义
BINARY_NAME=crane-autoscaling-example
DOCKER_IMAGE ?= "registry-dev.vestack.sbuxcf.net/platform-system-dev/crane-autoscaling-example:${GIT_VERSION}"

# 编译目标目录
BIN_DIR=bin

# 确保目标目录存在
$(shell mkdir -p $(BIN_DIR))

.PHONY: all clean build-mac build-linux docker

# 默认目标
all: build-mac build-linux

# 清理构建产物
clean:
	rm -rf $(BIN_DIR)

# 构建Mac版本
build-mac:
	CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build -o $(BIN_DIR)/$(BINARY_NAME)-darwin main.go

# 构建Linux版本
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $(BIN_DIR)/$(BINARY_NAME)-linux main.go

# 构建Docker镜像
image: build-linux
	cp $(BIN_DIR)/$(BINARY_NAME)-linux ./$(BINARY_NAME)
	docker buildx build --platform linux/amd64  -t $(DOCKER_IMAGE) .
	rm -f ./$(BINARY_NAME)