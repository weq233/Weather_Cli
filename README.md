# Weather CLI 🌤️

[![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?logo=go)](https://go.dev/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows-lightgrey)]()

一个基于 Go 语言的轻量级命令行天气查询工具,支持 Docker 容器化部署和多平台运行。

## 📋 目录

- [项目简介](#项目简介)
- [快速开始](#快速开始)
- [环境要求](#环境要求)
- [构建与部署](#构建与部署)
- [配置说明](#配置说明)
- [使用示例](#使用示例)
- [故障排查](#故障排查)

---

## 项目简介

Weather CLI 是一个基于 Go 语言的命令行天气查询工具,使用和风天气 API 提供实时天气数据。支持容器化部署,实现"开箱即用"的体验。

**核心特性:**
- ✅ 跨平台支持 (Windows 开发 → Linux 运行)
- ✅ 容器化部署 (Docker)
- ✅ 配置文件管理 (config.json)
- ✅ 多层级配置优先级
- ✅ 简洁的命令行界面

---

## 快速开始

### 方式 1: 直接使用容器(推荐)

```bash
# 在已安装 Docker 的 Debian 上执行
docker run --rm weather-cli:latest --city Beijing
```

### 方式 2: 创建便捷命令

```bash
# 创建全局命令
sudo tee /usr/local/bin/weather > /dev/null << 'EOF'
#!/bin/bash
docker run --rm --entrypoint ./weather-cli weather-cli:latest "$@"
EOF

sudo chmod +x /usr/local/bin/weather

# 使用
weather --city Beijing
weather --city Shanghai
```

---

## 环境要求

### 开发环境 (Windows)
- Windows 10/11
- PowerShell 5.1+ 或 PowerShell Core
- Go 1.21+
- Git

### 运行环境 (Debian/Linux)
- Debian 13 (或其他 Linux 发行版)
- Docker 20.10+
- 网络连接(访问和风天气 API)

---

## 构建与部署

### 步骤 1: 准备源代码

在 **Windows** 上打包源代码:

```powershell
cd "C:\Users\weq233\Desktop\代码\Weather_Cli"

# 压缩必要文件
Compress-Archive -Path cmd,config.json,Dockerfile,.dockerignore,go.mod,go.sum `
  -DestinationPath weather-cli-src.zip -Force

# 上传到 Debian
scp .\weather-cli-src.zip weq@10.17.8.200:/home/weq/
```

### 步骤 2: 在 Debian 上构建镜像

SSH 连接到 Debian 并执行:

```bash
# 连接
ssh 你的linux用户名称@linux的IP地址

# 切换到 root (或使用 sudo)
su root

# 解压源码
unzip /home/weq/weather-cli-src.zip -d /home/weq/weather-cli-build
cd /home/weq/weather-cli-build

# 构建 Docker 镜像
docker build -t weather-cli:latest .
```

**构建过程说明:**
1. **第一阶段 (builder)**: 使用 `golang:1.21-alpine` 编译 Go 程序
   - 配置国内 Go 模块代理 (`GOPROXY=https://goproxy.cn`)
   - 交叉编译为 Linux AMD64 二进制文件
   
2. **第二阶段 (runtime)**: 使用 `alpine:latest` 作为运行环境
   - 安装必要的 CA 证书和 Bash
   - 复制编译好的二进制和配置文件
   - 设置默认入口点

### 步骤 3: 验证构建

```bash
# 检查镜像
docker images | grep weather-cli

# 测试运行
docker run --rm weather-cli:latest --city Beijing

# 进入容器调试
docker run --rm --entrypoint bash weather-cli:latest -i -t
```

---

## 配置说明

### 配置文件 (config.json)

程序会自动读取运行目录下的 `config.json`:

```json
{
  "api_host": "和风天气 API Host",
  "api_key": "和风天气 API Key",
  "timeout": 10
}
```

**配置项说明:**
- `api_host`: 和风天气 API Host (从控制台获取)
- `api_key`: 和风天气 API Key (32位十六进制字符串)
- `timeout`: HTTP 请求超时时间(秒)

### 配置优先级

配置加载顺序(从高到低):
1. **命令行参数**: `--api-key`, `--api-host`
2. **环境变量**: `WEATHER_API_KEY`, `WEATHER_API_HOST`
3. **配置文件**: `config.json`
4. **代码默认值**: 内置的默认配置

### 修改配置

#### 方式 1: 编辑配置文件(推荐)

```bash
# 在 Debian 上编辑
nano config.json

# 修改后重新构建镜像
docker build -t weather-cli:latest .
```

#### 方式 2: 使用环境变量

```bash
docker run --rm \
  -e WEATHER_API_KEY="your_new_key" \
  -e WEATHER_API_HOST="your_host.qweatherapi.com" \
  weather-cli:latest --city Beijing
```

#### 方式 3: 使用命令行参数

```bash
docker run --rm weather-cli:latest \
  --api-key your_new_key \
  --city Beijing
```

---

## 使用示例

### 基本用法

```bash
# 查询城市天气
weather --city Beijing
weather --city Shanghai
weather --city Guangzhou

# 使用演示模式(无需 API Key)
weather --city Beijing --api-key demo
```

### 高级用法

```bash
# 查看帮助
weather --help

# 查看版本
weather version

# 查看配置信息
weather config
```

### 批量查询

```bash
# 查询多个城市
for city in Beijing Shanghai Guangzhou Shenzhen; do
  echo "=== $city ==="
  weather --city $city
  echo ""
done
```

---

## 故障排查

### 问题 1: Docker 权限不足

**错误信息:**
```
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```

**解决方案:**
```bash
# 将用户添加到 docker 组
sudo usermod -aG docker $USER

# 刷新用户组(或重新登录)
newgrp docker

# 验证
docker info
```

### 问题 2: 构建时网络超时

**错误信息:**
```
dial tcp 142.250.73.145:443: i/o timeout
```

**原因:** 无法访问 Go 模块代理

**解决方案:** Dockerfile 已配置国内代理,确保使用最新版本的 Dockerfile:
```dockerfile
ENV GOPROXY=https://goproxy.cn,https://proxy.golang.org,direct
```

### 问题 3: API 返回 404

**错误信息:**
```
Error: API 返回错误，code: 404
```

**可能原因:**
1. API Key 无效或过期
2. API Host 配置错误
3. GeoAPI 路径未包含 `/geo/` 前缀

**解决方案:**
```bash
# 1. 验证 API Key 和 Host
curl -v --compressed \
  -H "X-QW-Api-Key: f694dcb7ce394ffe93408aa83f92a54e" \
  "https://p54nmuk5rq.re.qweatherapi.com/geo/v2/city/lookup?location=Beijing"

# 2. 检查 config.json
cat config.json

# 3. 获取新的 API Key
# 访问 https://console.qweather.com/ 创建新项目
```

### 问题 4: 配置文件未加载

**错误信息:**
```
Error: 请提供 API Key (--api-key 或 WEATHER_API_KEY 环境变量)
```

**原因:** 容器内找不到 config.json

**解决方案:**
```bash
# 1. 检查容器内是否有配置文件
docker run --rm --entrypoint bash weather-cli:latest -c "ls -l /app/"

# 2. 手动挂载配置文件
docker run --rm \
  -v /path/to/config.json:/app/config.json \
  weather-cli:latest --city Beijing

# 3. 确保 Dockerfile 中有 COPY config.json
grep "COPY config.json" Dockerfile
```

### 问题 5: 容器内无法调试

**问题:** 无法使用 `docker run ... sh` 进入容器

**解决方案:** 使用 `--entrypoint` 覆盖默认入口点:
```bash
# 进入交互式 Shell
docker run --rm --entrypoint bash weather-cli:latest -i -t

# 执行单条命令
docker run --rm --entrypoint bash weather-cli:latest -c "cat /app/config.json"
```

---

## 获取 API Key

1. 访问 [和风天气控制台](https://console.qweather.com/)
2. 注册/登录账号
3. 创建新项目
4. 选择 "Web API" + "开发版(免费)"
5. 复制 API Key 和 API Host
6. 更新 `config.json`

**注意:** 
- 开发版免费版每日限额 1000 次调用
- API Host 格式: `xxx.xxx.qweatherapi.com`
- GeoAPI 路径需添加 `/geo/` 前缀

---

## 项目结构

```
weather-cli/
├── cmd/
│   ├── main.go          # 程序入口
│   └── root.go          # CLI 命令定义
├── config.json           # API 配置文件
├── Dockerfile            # Docker 构建文件
├── .dockerignore         # Docker 排除文件
├── go.mod                # Go 模块依赖
├── go.sum                # 依赖校验文件
└── README.md             # 项目文档
```

---

## 许可证

MIT License

---

## 常见问题 (FAQ)

### Q: 如何更新 API Key?
A: 编辑 `config.json`,然后重新构建镜像:
```bash
nano config.json
docker build -t weather-cli:latest .
```

### Q: 可以在没有 Docker 的环境下运行吗?
A: 可以,直接编译二进制文件:
```bash
GOOS=linux GOARCH=amd64 go build -o weather-cli ./cmd
./weather-cli --city Beijing
```


### Q: 支持哪些城市?
A: 支持和风天气 API 支持的所有城市,包括中文和英文城市名。

---

