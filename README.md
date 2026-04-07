---

## ✨ 特性

- 🖥️ **CLI 工具** - 命令行快速查询天气
- 🌐 **REST API** - 标准的 HTTP API 接口
- 📱 **移动端 App** - Flutter 跨平台应用（iOS/Android）
- 🐳 **容器化** - Docker 一键部署
- 🔧 **灵活配置** - 支持配置文件、环境变量、命令行参数
- 🚀 **跨平台** - Windows 开发，Linux 部署

---

## 📚 文档导航

### 🎯 快速开始

- **[⚙️ 配置指南](docs/CONFIG_GUIDE.md)** - 3 步完成配置（必读）

### 💻 开发文档

- **[💻 系统要求](docs/SYSTEM_REQUIREMENTS.md)** - 硬件和软件要求
- **[🌐 API 文档](docs/API_USAGE.md)** - REST API 接口说明
- **[🔑 Git 配置](docs/GIT_SETUP_GUIDE.md)** - 版本控制配置

### 🚀 部署运维

- **[🚀 部署指南](docs/DEPLOY_GUIDE.md)** - Windows → Linux 服务器部署

### 📱 移动端

- **[📱 快速开始](mobile/QUICK_START.md)** - 5 分钟运行移动应用
- **[🔧 Flutter 安装](mobile/FLUTTER_INSTALL_GUIDE.md)** - Flutter SDK 安装

📚 **查看全部文档**: [docs/README.md](docs/README.md)

---

## 🏗️ 项目结构

```
Weather_Cli/
├── docs/                    # 📚 文档中心
│   ├── README.md           # 文档索引
│   ├── CONFIG_GUIDE.md     # 配置指南
│   ├── DEPLOY_GUIDE.md     # 部署指南
│   ├── API_USAGE.md        # API 文档
│   ├── SYSTEM_REQUIREMENTS.md  # 系统要求
│   └── GIT_SETUP_GUIDE.md  # Git 配置
│
├── cmd/                     # 🚀 CLI 命令行工具
│   ├── main.go
│   └── root.go
│
├── api/                     # 🌐 API 服务
│   ├── server.go
│   ├── handlers.go
│   └── routes.go
│
├── internal/                # 🔧 核心业务逻辑
│   ├── config/             # 配置管理
│   └── weather/            # 天气查询
│
├── mobile/                  # 📱 移动端应用
│   └── weather_app/        # Flutter 项目
│
├── config.json              # 配置文件
├── Dockerfile               # Docker 构建文件
├── docker-compose.yml       # Docker Compose 配置
└── Makefile                 # 自动化构建脚本
```

---

## 🚀 快速开始

### 1️⃣ 配置 API Key

创建并编辑 `config.json`：

``powershell
# Windows - 创建配置文件
notepad config.json
```

**必须修改以下两项：**

```json
{
  "api": {
    "host": "从和风天气控制台获取",  // ⚠️ 必须修改
    "key": "从和风天气控制台获取",   // ⚠️ 必须修改
    "timeout": 10
  },
  "server": {
    "port": 8080,
    "mode": "release"
  }
}
```

**如何获取 Host 和 Key：**
1. 访问 https://console.qweather.com/
2. 注册/登录账号
3. 创建新项目
4. 在项目中找到 **Host** 和 **Key**
5. 复制到配置文件中

### 2️⃣ 使用 CLI

```bash
# 编译
go build -o weather-cli.exe ./cmd

# 查询天气
./weather-cli.exe --city 北京
```

### 3️⃣ 启动 API 服务

```bash
# 编译 API
go build -o weather-api.exe ./api

# 启动服务
./weather-api.exe

# 访问 API
curl http://localhost:8080/api/weather?city=北京
```

### 4️⃣ Docker 部署

```bash
# 构建镜像
docker build -t weather-cli:latest .

# 运行容器
docker run -p 8080:8080 weather-cli:latest
```

---

## 📱 移动端应用

完整的 Flutter 跨平台移动应用（iOS/Android）：

### 快速开始（5 分钟）

**⚠️ 前置要求：**
- 确保至少 **10 GB** 可用磁盘空间
- 已安装 [Flutter SDK](mobile/FLUTTER_INSTALL_GUIDE.md)

```bash
# 1. 启动 API 服务
go build -o weather-api.exe ./api && ./weather-api.exe

# 2. 进入移动端目录
cd mobile/weather_app

# 3. 安装依赖
flutter pub get

# 4. 运行应用（自动检测 Flutter）
flutter run

# 或使用智能启动脚本（推荐）
cd ../..
.\mobile\run-app.ps1  # Windows
./mobile/run-app.sh   # Linux/Mac
```

📖 **详细文档**: 
- [⚡ 快速开始](mobile/QUICK_START.md) - 5 分钟上手（含磁盘空间检查）
- [📘 开发指南](mobile/MOBILE_DEV_GUIDE.md) - 完整教程
- [🔧 Flutter 安装](mobile/FLUTTER_INSTALL_GUIDE.md) - 详细的安装指南

---

## 🔧 常用命令

```bash
# 编译
make build

# 运行 CLI
make run

# 启动 API
make run-api

# Docker 构建
make docker-build

# 清理
make clean
```

查看所有命令: `make help`

---

## 🌐 API 端点

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/health` | GET | 健康检查 |
| `/api/weather?city=北京` | GET | 查询天气 |
| `/api/version` | GET | 版本信息 |

📖 完整 API 文档: [API_USAGE.md](docs/API_USAGE.md)

---

## 🚀 部署到 Linux 服务器

项目支持从 Windows 编译打包，通过 SSH 上传到 Linux 服务器进行容器化部署。

### 快速部署流程

**Windows 端：**
```powershell
# 1. 编译
go build -ldflags="-w -s" -o weather-api.exe ./api

# 2. 打包
Compress-Archive -Path weather-api.exe,config.json,Dockerfile,docker-compose.yml,Makefile,.dockerignore -DestinationPath deploy.zip -Force

# 3. 上传（替换为你的服务器 IP）
scp deploy.zip root@YOUR_SERVER_IP:/opt/weather-cli/
```

**Linux 服务器端：**
```bash
# 1. 登录并解压
ssh root@YOUR_SERVER_IP
cd /opt/weather-cli
unzip deploy.zip

# 2. 构建并启动
docker build -t weather-cli:latest .
docker-compose up -d

# 3. 验证
curl http://localhost:8080/api/health
```

📖 详细文档: [部署指南](docs/DEPLOY_GUIDE.md)

---

## 📖 更多文档

所有文档已整理到 [`docs/`](docs/) 目录：

- ⚙️ [配置指南](docs/CONFIG_GUIDE.md) - 完整的配置说明
- 🚀 [部署指南](docs/DEPLOY_GUIDE.md) - 服务器部署
- 🌐 [API 文档](docs/API_USAGE.md) - 接口说明
- 💻 [系统要求](docs/SYSTEM_REQUIREMENTS.md) - 硬件和软件要求
- 📱 [移动端开发](mobile/MOBILE_DEV_GUIDE.md) - Flutter 应用
- 🔑 [Git 配置](docs/GIT_SETUP_GUIDE.md) - 版本控制

📚 **查看全部文档**: [docs/README.md](docs/README.md)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

📖 开发指南: [Git 配置](docs/GIT_SETUP_GUIDE.md)

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

- [和风天气](https://www.qweather.com/) - 提供天气数据 API
- [Cobra](https://github.com/spf13/cobra) - CLI 框架
- [Gin](https://github.com/gin-gonic/gin) - Web 框架
- [Flutter](https://flutter.dev/) - 跨平台移动开发

---

**⭐ 如果这个项目对你有帮助，请给个 Star！**
