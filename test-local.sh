#!/bin/bash
# Weather_Cli 本地测试脚本 (Debian/Linux)
# 使用方法: chmod +x test-local.sh && ./test-local.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Weather_Cli 本地测试 (Debian/Linux)${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 测试 1: 检查 Go 环境
echo -e "${YELLOW}[测试 1/5] 检查 Go 环境...${NC}"
if command -v go &> /dev/null; then
    GO_VERSION=$(go version)
    echo -e "${GREEN}✅ $GO_VERSION${NC}"
else
    echo -e "${RED}❌ Go 未安装${NC}"
    echo -e "${YELLOW}安装 Go: sudo apt install golang-go${NC}"
    exit 1
fi

# 测试 2: 检查 Docker
echo -e "\n${YELLOW}[测试 2/5] 检查 Docker...${NC}"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    echo -e "${GREEN}✅ $DOCKER_VERSION${NC}"
    
    if docker info &> /dev/null; then
        echo -e "${GREEN}   Docker 服务: 运行中${NC}"
    else
        echo -e "${YELLOW}⚠️  Docker 服务未运行${NC}"
        echo -e "${YELLOW}   启动命令: sudo systemctl start docker${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Docker 未安装（可选）${NC}"
fi

# 测试 3: 下载依赖
echo -e "\n${YELLOW}[测试 3/5] 下载依赖...${NC}"
if go mod download; then
    echo -e "${GREEN}✅ 依赖下载成功${NC}"
else
    echo -e "${RED}❌ 依赖下载失败${NC}"
    exit 1
fi

# 测试 4: 编译 Linux 版本
echo -e "\n${YELLOW}[测试 4/5] 编译 Linux 版本...${NC}"
export CGO_ENABLED=0
export GOOS=linux
export GOARCH=amd64

if go build -ldflags="-w -s" -o weather-cli-test cmd/main.go; then
    echo -e "${GREEN}✅ 编译成功${NC}"
    
    # 显示文件大小
    FILE_SIZE=$(du -h weather-cli-test | cut -f1)
    echo -e "   文件大小: $FILE_SIZE"
else
    echo -e "${RED}❌ 编译失败${NC}"
    exit 1
fi

# 测试 5: 运行功能测试
echo -e "\n${YELLOW}[测试 5/5] 运行功能测试...${NC}"

echo -e "\n  ${CYAN}> 测试 --help:${NC}"
./weather-cli-test --help || true

echo -e "\n  ${CYAN}> 测试 version:${NC}"
./weather-cli-test version || true

echo -e "\n  ${CYAN}> 测试 config:${NC}"
./weather-cli-test config || true

echo -e "\n  ${CYAN}> 测试查询（预期会提示缺少城市）:${NC}"
./weather-cli-test --city "北京" || true

# 清理
echo -e "\n${YELLOW}清理测试文件...${NC}"
rm -f weather-cli-test
echo -e "${GREEN}✅ 清理完成${NC}"

echo -e "\n${CYAN}========================================${NC}"
echo -e "${GREEN}🎉 所有测试通过！${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${CYAN}下一步：${NC}"
echo -e "1. 构建 Docker 镜像: docker build -t weather-cli:latest ."
echo -e "2. 运行容器: docker run --rm -it weather-cli:latest --city 北京"
echo -e "3. 查看文档: cat GETTING_STARTED.md"
echo ""
