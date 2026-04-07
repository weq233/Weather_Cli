.PHONY: help build build-api run run-api test clean docker-build docker-run docker-push

# 默认目标
help:
	@echo "Weather CLI & API - Makefile"
	@echo ""
	@echo "可用命令:"
	@echo "  构建命令:"
	@echo "    make build         - 编译 CLI 二进制文件"
	@echo "    make build-api     - 编译 API 服务二进制文件"
	@echo "    make build-all     - 编译 CLI 和 API"
	@echo ""
	@echo "  运行命令:"
	@echo "    make run           - 运行 CLI 本地测试"
	@echo "    make run-api       - 运行 API 服务本地测试"
	@echo "    make dev           - CLI 开发模式"
	@echo "    make dev-api       - API 开发模式"
	@echo ""
	@echo "  测试命令:"
	@echo "    make test          - 运行测试"
	@echo "    make fmt           - 格式化代码"
	@echo "    make lint          - 代码检查"
	@echo ""
	@echo "  Docker 命令:"
	@echo "    make docker-build  - 构建 Docker 镜像"
	@echo "    make docker-run    - 运行 Docker CLI 容器"
	@echo "    make docker-run-api - 运行 Docker API 容器"
	@echo "    make docker-stop   - 停止 Docker 容器"
	@echo "    make docker-push   - 推送 Docker 镜像到仓库"
	@echo ""
	@echo "  Docker Compose 命令:"
	@echo "    make compose-up    - 使用 docker-compose 启动"
	@echo "    make compose-down  - 使用 docker-compose 停止"
	@echo "    make logs          - 查看容器日志"
	@echo ""
	@echo "  其他命令:"
	@echo "    make clean         - 清理构建产物"
	@echo "    make docs          - 生成文档"
	@echo ""

# ==================== 构建命令 ====================

# 编译 CLI 二进制文件
build:
	@echo "==> 编译 CLI 二进制文件..."
	CGO_ENABLED=0 go build -ldflags="-w -s" -o weather-cli cmd/main.go

# 编译 API 服务二进制文件
build-api:
	@echo "==> 编译 API 服务二进制文件..."
	CGO_ENABLED=0 go build -ldflags="-w -s" -o weather-api cmd/api/main.go

# 编译所有
build-all: build build-api
	@echo "==> 编译完成 (CLI + API)"

# ==================== 运行命令 ====================

# 运行 CLI 本地测试
run: build
	@echo "==> 运行 CLI 程序..."
	./weather-cli

# 运行 API 服务本地测试
run-api: build-api
	@echo "==> 运行 API 服务..."
	./weather-api

# CLI 开发模式 (热重载)
dev:
	@echo "==> CLI 开发模式..."
	go run cmd/main.go

# API 开发模式 (热重载)
dev-api:
	@echo "==> API 开发模式..."
	go run cmd/api/main.go

# ==================== 测试命令 ====================

# 运行测试
test:
	@echo "==> 运行测试..."
	go test -v ./...

# 格式化代码
fmt:
	@echo "==> 格式化代码..."
	go fmt ./...

# 代码检查
lint:
	@echo "==> 代码检查..."
	golangci-lint run

# ==================== 清理命令 ====================

# 清理
clean:
	@echo "==> 清理构建产物..."
	rm -f weather-cli weather-api
	rm -rf dist/

# ==================== Docker 命令 ====================

# 构建 Docker 镜像
docker-build:
	@echo "==> 构建 Docker 镜像..."
	docker build -t weather-cli:latest .

# 构建多平台镜像
docker-build-multiplatform:
	@echo "==> 构建多平台 Docker 镜像..."
	docker buildx build --platform linux/amd64,linux/arm64 -t weather-cli:latest --push .

# 运行 Docker CLI 容器
docker-run:
	@echo "==> 运行 Docker CLI 容器..."
	docker run --rm -it \
		-e TZ=Asia/Shanghai \
		-v $(PWD)/data:/home/appuser/data \
		weather-cli:latest

# 运行 Docker API 容器
docker-run-api:
	@echo "==> 运行 Docker API 容器..."
	docker run --rm -it \
		-p 8080:8080 \
		-e APP_MODE=api \
		-e API_PORT=8080 \
		-e TZ=Asia/Shanghai \
		weather-cli:latest

# 停止 Docker 容器
docker-stop:
	@echo "==> 停止 Docker 容器..."
	docker stop $$(docker ps -q --filter ancestor=weather-cli) || true

# 推送 Docker 镜像
docker-push:
	@echo "==> 推送 Docker 镜像..."
	docker tag weather-cli:latest your-registry/weather-cli:latest
	docker push your-registry/weather-cli:latest

# ==================== Docker Compose 命令 ====================

# Docker Compose 启动
compose-up:
	@echo "==> 使用 Docker Compose 启动..."
	docker-compose up -d

# Docker Compose 停止
compose-down:
	@echo "==> 使用 Docker Compose 停止..."
	docker-compose down

# 查看日志
logs:
	@echo "==> 查看容器日志..."
	docker-compose logs -f

# ==================== 其他命令 ====================

# 生成文档
docs:
	@echo "==> 生成文档..."
	go doc ./...
