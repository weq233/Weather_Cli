# 系统要求 🖥️

运行 Weather CLI 项目各组件的系统要求。

---

## 💻 开发环境要求

### Windows（推荐开发平台）

| 组件 | 最低要求 | 推荐配置 |
|------|---------|---------|
| **操作系统** | Windows 10 (64-bit) | Windows 11 |
| **内存** | 4 GB RAM | 8 GB RAM |
| **磁盘空间** | 10 GB 可用空间 | 20 GB SSD |
| **Go 版本** | 1.21+ | 1.21+ |
| **Git** | 2.x+ | 最新稳定版 |

### Linux（推荐部署平台）

| 组件 | 最低要求 | 推荐配置 |
|------|---------|---------|
| **操作系统** | Debian 13+ / Ubuntu 20.04+ | Debian 13 / Ubuntu 22.04 LTS |
| **内存** | 512 MB RAM | 2 GB RAM |
| **磁盘空间** | 2 GB 可用空间 | 10 GB SSD |
| **Docker** | 20.10+ | 最新稳定版 |
| **网络** | 能访问外网 | 稳定的网络连接 |

### macOS（可选，用于 iOS 开发）

| 组件 | 最低要求 | 推荐配置 |
|------|---------|---------|
| **操作系统** | macOS 10.15+ | macOS 13+ |
| **内存** | 4 GB RAM | 8 GB RAM |
| **磁盘空间** | 10 GB 可用空间 | 20 GB SSD |
| **Xcode** | 13.0+ | 最新版本 |

---

## 📱 移动端开发要求

### Flutter SDK

| 组件 | 所需空间 | 说明 |
|------|---------|------|
| **Flutter SDK** | ~1 GB | 核心框架和工具链 |
| **Android SDK** | ~5 GB | Android 开发工具和系统镜像 |
| **项目依赖** | ~500 MB | Flutter 包和第三方库 |
| **构建缓存** | ~2 GB | 编译中间文件和缓存 |
| **总计** | **建议预留 10 GB** | 确保流畅开发和构建 |

### Android 开发

| 组件 | 要求 |
|------|------|
| **Android Studio** | 最新稳定版 |
| **Android SDK** | API 33+ (Android 13) |
| **JDK** | 11 或 17 |
| **模拟器** | 至少 2 GB RAM 分配 |

### iOS 开发（仅 macOS）

| 组件 | 要求 |
|------|------|
| **Xcode** | 13.0+ |
| **iOS Simulator** | iOS 15+ |
| **CocoaPods** | 1.11+ |

---

## 🌐 API 服务要求

### 本地开发

| 组件 | 要求 |
|------|------|
| **Go** | 1.21+ |
| **内存** | 256 MB |
| **CPU** | 单核即可 |
| **网络** | 能访问和风天气 API |

### Docker 部署

| 组件 | 要求 |
|------|------|
| **Docker** | 20.10+ |
| **Docker Compose** | 2.0+ |
| **内存** | 512 MB（容器） |
| **磁盘** | 1 GB（镜像 + 数据） |

---

## 📊 资源占用估算

### 开发阶段

```
┌─────────────────────────┐
│  Go 开发环境            │
│  - Go SDK:      500 MB  │
│  - 项目代码:    50 MB   │
│  - 依赖缓存:    200 MB  │
├─────────────────────────┤
│  Flutter 开发环境       │
│  - Flutter SDK: 1 GB    │
│  - Android SDK: 5 GB    │
│  - 项目依赖:    500 MB  │
│  - 构建缓存:    2 GB    │
├─────────────────────────┤
│  总计:          ~9.2 GB │
│  建议预留:      10-15 GB│
└─────────────────────────┘
```

### 生产部署（Linux 服务器）

```
┌─────────────────────────┐
│  Docker 环境            │
│  - Docker Engine: 500MB │
│  - 应用镜像:    100 MB  │
│  - 运行容器:    50 MB   │
├─────────────────────────┤
│  总计:          ~650 MB │
│  建议预留:      2 GB    │
└─────────────────────────┘
```

---

## 🔍 检查系统要求

### Windows

```powershell
# 检查磁盘空间
Get-PSDrive C | Select-Object Used,Free

# 检查内存
systeminfo | findstr "物理内存"

# 检查 Go 版本
go version

# 检查 Flutter（如果已安装）
flutter doctor
```

### Linux

```bash
# 检查磁盘空间
df -h /

# 检查内存
free -h

# 检查 Docker
docker --version
docker-compose --version

# 检查 Go（如果已安装）
go version
```

### macOS

```bash
# 检查磁盘空间
df -h /

# 检查内存
vm_stat

# 检查 Xcode
xcodebuild -version

# 检查 Flutter（如果已安装）
flutter doctor
```

---

## ⚠️ 常见问题

### Q1: 磁盘空间不足怎么办？

**解决方案：**
1. 清理临时文件
   - Windows: `cleanmgr`（磁盘清理）
   - Linux: `sudo apt clean`
2. 卸载不需要的应用
3. 移动大文件到其他磁盘
4. 使用外部存储（不推荐用于 SDK）

### Q2: 内存不足导致构建失败？

**解决方案：**
1. 关闭其他应用程序
2. 增加虚拟内存/交换空间
3. 降低并发构建数量
4. 考虑升级物理内存

### Q3: Docker 权限问题？

**Linux 解决方案：**
```bash
# 将用户加入 docker 组
sudo usermod -aG docker $USER

# 重新登录或重启
newgrp docker
```

### Q4: 网络速度慢？

**国内用户优化：**

配置 Go 代理：
```bash
go env -w GOPROXY=https://goproxy.cn,direct
```

配置 Flutter 镜像：
```bash
# Windows PowerShell
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

# Linux/Mac
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
```

---

## 📋 快速检查清单

在开始开发前，确认以下项：

### 开发环境
- [ ] 操作系统符合要求
- [ ] 至少 10 GB 可用磁盘空间
- [ ] 至少 4 GB 可用内存
- [ ] Go 1.21+ 已安装
- [ ] Git 已安装并配置
- [ ] （可选）Flutter SDK 已安装

### 部署环境
- [ ] Linux 服务器可访问
- [ ] Docker 20.10+ 已安装
- [ ] 至少 2 GB 可用磁盘空间
- [ ] 至少 512 MB 可用内存
- [ ] 网络连接正常

### 移动端开发
- [ ] 10 GB 可用磁盘空间
- [ ] Flutter SDK 已安装
- [ ] Android Studio 已安装（Android 开发）
- [ ] Xcode 已安装（iOS 开发，仅 macOS）
- [ ] 模拟器或真机已准备

---

## 🎯 下一步

确认系统要求后：

1. 📘 [安装 Flutter](mobile/FLUTTER_INSTALL_GUIDE.md) - 如果需要开发移动端
2. 🚀 [快速开始](README.md) - 开始使用项目
3. 📝 [配置指南](docs/CONFIG_GUIDE.md) - 配置 API Key
4. 🌐 [部署指南](docs/DEPLOY_GUIDE.md) - 部署到服务器

---

*最后更新: 2026-04-07*
