.PHONY: help build run test clean docker-build docker-run docker-push

# 默认目标
help:
	@echo "Go CLI 容器化分发 Makefile"
	@echo ""
	@echo "可用命令:"
	@echo "  make build         - 编译 Go 二进制文件"
	@echo "  make run           - 运行本地测试"
	@echo "  make test          - 运行测试"
	@echo "  make clean         - 清理构建产物"
	@echo "  make docker-build  - 构建 Docker 镜像"
	@echo "  make docker-run    - 运行 Docker 容器"
	@echo "  make docker-stop   - 停止 Docker 容器"
	@echo "  make docker-push   - 推送 Docker 镜像到仓库"
	@echo "  make compose-up    - 使用 docker-compose 启动"
	@echo "  make compose-down  - 使用 docker-compose 停止"
	@echo ""

# 编译二进制文件
build:
	@echo "==> 编译二进制文件..."
	CGO_ENABLED=0 go build -ldflags="-w -s" -o weather-cli cmd/main.go

# 运行本地测试
run:
	@echo "==> 运行本地程序..."
	./weather-cli

# 运行测试
test:
	@echo "==> 运行测试..."
	go test -v ./...

# 清理
clean:
	@echo "==> 清理构建产物..."
	rm -f weather-cli
	rm -rf dist/

# 构建 Docker 镜像
docker-build:
	@echo "==> 构建 Docker 镜像..."
	docker build -t weather-cli:latest .

# 构建多平台镜像
docker-build-multiplatform:
	@echo "==> 构建多平台 Docker 镜像..."
	docker buildx build --platform linux/amd64,linux/arm64 -t weather-cli:latest --push .

# 运行 Docker 容器
docker-run:
	@echo "==> 运行 Docker 容器..."
	docker run --rm -it \
		-e TZ=Asia/Shanghai \
		-v $(PWD)/data:/home/appuser/data \
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

# 开发模式 (热重载)
dev:
	@echo "==> 开发模式..."
	go run cmd/main.go

# 格式化代码
fmt:
	@echo "==> 格式化代码..."
	go fmt ./...

# 代码检查
lint:
	@echo "==> 代码检查..."
	golangci-lint run

# 生成文档
docs:
	@echo "==> 生成文档..."
	go doc ./...
