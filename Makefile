# 基础变量定义
BINARY_NAME=crane-autoscaling-example
DOCKER_IMAGE=crane-autoscaling-example
DOCKER_TAG=latest

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
docker: build-linux
	cp $(BIN_DIR)/$(BINARY_NAME)-linux ./$(BINARY_NAME)
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	rm -f ./$(BINARY_NAME)