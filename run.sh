#!/bin/bash
# Weather_Cli 运行脚本 (Debian 13)
# 使用方法: ./run.sh [选项]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 配置
BINARY_NAME="weather-cli"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY_PATH="${SCRIPT_DIR}/${BINARY_NAME}"

# 打印帮助信息
print_help() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}Weather_Cli 运行工具${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo "用法: $0 [命令] [选项]"
    echo ""
    echo "命令:"
    echo "  test        运行基本功能测试"
    echo "  run         交互式运行（需要手动输入参数）"
    echo "  query       查询指定城市天气"
    echo "  docker      使用 Docker 运行"
    echo "  install     安装到系统路径"
    echo "  status      检查运行环境"
    echo "  help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 test"
    echo "  $0 query --city 北京"
    echo "  $0 docker --city 上海"
    echo ""
}

# 检查二进制文件
check_binary() {
    if [ ! -f "$BINARY_PATH" ]; then
        echo -e "${RED}❌ 错误: 未找到 ${BINARY_NAME}${NC}"
        echo -e "${YELLOW}提示: 请先从 Windows 部署或本地编译${NC}"
        exit 1
    fi
    
    if [ ! -x "$BINARY_PATH" ]; then
        echo -e "${YELLOW}⚠️  设置执行权限...${NC}"
        chmod +x "$BINARY_PATH"
    fi
}

# 检查 Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker 未安装${NC}"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}❌ Docker 服务未运行${NC}"
        echo -e "${YELLOW}启动 Docker: sudo systemctl start docker${NC}"
        exit 1
    fi
}

# 运行测试
run_test() {
    echo -e "${CYAN}[测试 1/3] 检查版本...${NC}"
    "$BINARY_PATH" version
    
    echo -e "\n${CYAN}[测试 2/3] 查看配置...${NC}"
    "$BINARY_PATH" config
    
    echo -e "\n${CYAN}[测试 3/3] 查询天气（示例）...${NC}"
    "$BINARY_PATH" --city "北京"
    
    echo -e "\n${GREEN}✅ 所有测试完成${NC}"
}

# 交互式运行
run_interactive() {
    echo -e "${CYAN}请输入城市名称:${NC}"
    read -p "> " CITY
    
    if [ -z "$CITY" ]; then
        echo -e "${RED}❌ 城市名称不能为空${NC}"
        exit 1
    fi
    
    echo -e "\n${CYAN}正在查询 ${CITY} 的天气...${NC}"
    "$BINARY_PATH" --city "$CITY"
}

# 查询指定城市
query_weather() {
    local city="$1"
    
    if [ -z "$city" ]; then
        echo -e "${RED}❌ 请指定城市名称${NC}"
        echo -e "${YELLOW}用法: $0 query --city 北京${NC}"
        exit 1
    fi
    
    "$BINARY_PATH" --city "$city"
}

# 使用 Docker 运行
run_docker() {
    check_docker
    
    local city="$1"
    local api_key="${WEATHER_API_KEY:-}"
    
    echo -e "${CYAN}使用 Docker 运行 Weather_Cli...${NC}"
    
    # 构建镜像（如果不存在）
    if ! docker images | grep -q "weather-cli"; then
        echo -e "${YELLOW}构建 Docker 镜像...${NC}"
        cd "$SCRIPT_DIR"
        docker build -t weather-cli:latest .
    fi
    
    # 运行容器
    local docker_cmd="docker run --rm -it \
        -e TZ=Asia/Shanghai \
        -v ${SCRIPT_DIR}/data:/home/appuser/data"
    
    if [ -n "$api_key" ]; then
        docker_cmd="$docker_cmd -e WEATHER_API_KEY=$api_key"
    fi
    
    if [ -n "$city" ]; then
        docker_cmd="$docker_cmd weather-cli:latest --city $city"
    else
        docker_cmd="$docker_cmd weather-cli:latest"
    fi
    
    eval $docker_cmd
}

# 安装到系统路径
install_system() {
    echo -e "${CYAN}安装到系统路径...${NC}"
    
    local install_path="/usr/local/bin/${BINARY_NAME}"
    
    sudo cp "$BINARY_PATH" "$install_path"
    sudo chmod +x "$install_path"
    
    echo -e "${GREEN}✅ 安装成功: ${install_path}${NC}"
    echo -e "${YELLOW}现在可以在任何位置运行: ${BINARY_NAME}${NC}"
}

# 检查环境状态
check_status() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}系统环境检查${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    
    # 检查操作系统
    echo -e "${YELLOW}操作系统:${NC}"
    cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"'
    echo ""
    
    # 检查 Go（如果从源码构建）
    if command -v go &> /dev/null; then
        echo -e "${YELLOW}Go 版本:${NC} $(go version)"
    else
        echo -e "${YELLOW}Go 版本:${NC} 未安装（不需要，使用预编译二进制）"
    fi
    echo ""
    
    # 检查 Docker
    if command -v docker &> /dev/null; then
        echo -e "${YELLOW}Docker 版本:${NC} $(docker --version)"
        if docker info &> /dev/null; then
            echo -e "${GREEN}   状态: 运行中${NC}"
        else
            echo -e "${RED}   状态: 未运行${NC}"
        fi
    else
        echo -e "${YELLOW}Docker:${NC} 未安装"
    fi
    echo ""
    
    # 检查二进制文件
    if [ -f "$BINARY_PATH" ]; then
        echo -e "${YELLOW}二进制文件:${NC} 存在"
        echo -e "${YELLOW}文件路径:${NC} $BINARY_PATH"
        echo -e "${YELLOW}文件大小:${NC} $(du -h "$BINARY_PATH" | cut -f1)"
        echo -e "${YELLOW}执行权限:${NC} $([ -x "$BINARY_PATH" ] && echo '是' || echo '否')"
    else
        echo -e "${RED}二进制文件:${NC} 不存在"
    fi
    echo ""
    
    # 检查网络连接
    echo -e "${YELLOW}网络连通性:${NC}"
    if ping -c 1 -W 2 8.8.8.8 &> /dev/null; then
        echo -e "${GREEN}   ✅ 外网访问正常${NC}"
    else
        echo -e "${RED}   ❌ 外网访问失败${NC}"
    fi
    echo ""
}

# 主逻辑
main() {
    local command="${1:-help}"
    shift || true
    
    case "$command" in
        test)
            check_binary
            run_test
            ;;
        run)
            check_binary
            run_interactive
            ;;
        query)
            check_binary
            # 解析 --city 参数
            local city=""
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --city|-c)
                        city="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            query_weather "$city"
            ;;
        docker)
            # 解析参数
            local city=""
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --city|-c)
                        city="$2"
                        shift 2
                        ;;
                    *)
                        shift
                        ;;
                esac
            done
            run_docker "$city"
            ;;
        install)
            check_binary
            install_system
            ;;
        status)
            check_status
            ;;
        help|--help|-h)
            print_help
            ;;
        *)
            echo -e "${RED}未知命令: $command${NC}"
            print_help
            exit 1
            ;;
    esac
}

main "$@"
