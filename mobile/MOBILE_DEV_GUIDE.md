# 移动端开发快速指南 📱

## 🎯 概述

本项目提供了一个完整的 **Flutter 跨平台移动应用**，可以同时部署到 iOS 和 Android 平台。

---

## 📋 前置要求

### 1. 安装 Flutter SDK

**Windows:**
```powershell
# 下载 Flutter SDK
# https://flutter.dev/docs/get-started/install/windows

# 解压到 C:\src\flutter

# 添加到 PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", "User")

# 验证安装
flutter doctor
```

**macOS:**
```bash
# 使用 Homebrew 安装
brew install --cask flutter

# 或手动下载安装
# https://flutter.dev/docs/get-started/install/macos

# 验证安装
flutter doctor
```

**Linux:**
```bash
# 下载 Flutter
cd ~
git clone https://github.com/flutter/flutter.git -b stable

# 添加到 PATH
export PATH="$PATH:`pwd`/flutter/bin"

# 验证安装
flutter doctor
```

### 2. 安装 IDE（推荐）

- **VS Code**: 安装 Flutter 和 Dart 插件
- **Android Studio**: 安装 Flutter 插件
- **IntelliJ IDEA**: 安装 Flutter 插件

### 3. 安装平台依赖

**Android:**
- 安装 Android Studio
- 安装 Android SDK
- 配置 Android 模拟器

**iOS (仅 macOS):**
- 安装 Xcode
- 安装 CocoaPods: `sudo gem install cocoapods`
- 配置 iOS 模拟器

---

## 🚀 快速开始

### 步骤 1: 启动 API 服务

确保 Weather API 服务正在运行：

```bash
# 本地运行
cd ../..
make run-api

# 或 Docker 运行
docker run -d -p 8080:8080 -e APP_MODE=api weather-cli:latest
```

### 步骤 2: 配置 API 地址

编辑 `mobile/weather_app/lib/services/weather_service.dart`:

```dart
// 根据运行环境修改 baseUrl
static const String baseUrl = 'http://10.0.2.2:8080/api';  // Android 模拟器
// static const String baseUrl = 'http://localhost:8080/api';  // iOS 模拟器
// static const String baseUrl = 'http://YOUR_IP:8080/api';  // 真机测试
```

### 步骤 3: 安装依赖

```bash
cd mobile/weather_app
flutter pub get
```

### 步骤 4: 运行应用

**方式 A: 使用命令行**
```bash
# 查看可用设备
flutter devices

# 运行到指定设备
flutter run -d <device_id>

# 或直接运行（自动选择设备）
flutter run
```

**方式 B: 使用 IDE**
1. 在 VS Code 中打开项目
2. 按 `F5` 或点击 "Run" → "Start Debugging"
3. 选择目标设备

**方式 C: 使用快捷脚本**
```bash
# Windows
.\run-app.ps1

# Linux/Mac
chmod +x run-app.sh
./run-app.sh
```

---

## 📱 设备配置

### Android 模拟器

1. 打开 Android Studio
2. Tools → Device Manager
3. Create Device
4. 选择设备型号和系统版本
5. 启动模拟器

### iOS 模拟器 (macOS)

```bash
# 列出可用模拟器
xcrun simctl list devices

# 启动模拟器
open -a Simulator

# 或在 Xcode 中
# Xcode → Preferences → Components → 下载模拟器
```

### 真机测试

**Android:**
1. 启用开发者选项
2. 启用 USB 调试
3. 连接电脑
4. 运行 `flutter devices` 查看设备

**iOS:**
1. 信任电脑
2. 在 Xcode 中配置签名
3. 连接电脑
4. 运行 `flutter devices`

---

## 🔧 常用命令

### 开发

```bash
# 热重载 (运行中按 r)
# 热重启 (运行中按 R)

# 清理并重新构建
flutter clean
flutter pub get
flutter run

# 代码格式化
flutter format .

# 代码检查
flutter analyze
```

### 构建

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release

# 查看所有构建选项
flutter build --help
```

### 测试

```bash
# 运行测试
flutter test

# 生成测试覆盖率报告
flutter test --coverage
```

---

## 🎨 自定义开发

### 修改主题颜色

编辑 `lib/main.dart`:

```dart
theme: ThemeData(
  primarySwatch: Colors.blue,  // 改为 Colors.green, Colors.purple 等
  useMaterial3: true,
),
```

### 添加新页面

1. 在 `lib/screens/` 创建新页面文件
2. 在 `lib/main.dart` 中注册路由
3. 添加导航逻辑

### 修改 API 超时时间

编辑 `lib/services/weather_service.dart`:

```dart
.timeout(const Duration(seconds: 15));  // 修改秒数
```

### 添加缓存功能

可以使用 `shared_preferences` 或 `hive` 包实现本地缓存。

---

## 🐛 调试技巧

### 查看日志

```bash
# 实时日志
flutter logs

# 或在 IDE 的 Debug Console 中查看
```

### DevTools

```bash
# 启动 DevTools
flutter pub global activate devtools
flutter pub global run devtools

# 访问 http://127.0.0.1:9100
```

### 性能分析

```bash
# 性能分析模式
flutter run --profile

# 或使用 DevTools 的 Performance 标签
```

---

## 📦 发布应用

### Android 发布

1. **生成密钥库**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **配置签名**
创建 `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. **构建 Release APK**
```bash
flutter build apk --release
```

4. **上传到 Google Play**
- 访问 Google Play Console
- 创建应用
- 上传 APK/AAB 文件

### iOS 发布 (macOS)

1. **配置 Apple Developer 账号**
- 注册 Apple Developer Program ($99/年)
- 在 Xcode 中登录账号

2. **配置签名**
- Xcode → Signing & Capabilities
- 选择 Team
- 自动管理签名

3. **构建 Archive**
```bash
flutter build ios --release
```

4. **上传到 App Store**
- Xcode → Product → Archive
- Distribute App
- 按照向导上传

详细指南: https://flutter.dev/docs/deployment

---

## 🌐 网络配置

### Android 允许 HTTP

编辑 `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### iOS 允许 HTTP

编辑 `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**注意**: 生产环境建议使用 HTTPS！

---

## 📊 性能优化

### 1. 减少 APK 体积

```bash
# 启用代码压缩
flutter build apk --release --split-per-abi

# 移除未使用的资源
flutter build apk --release --shrink
```

### 2. 图片优化

- 使用 WebP 格式
- 提供多分辨率图片
- 使用网络图片缓存

### 3. 网络优化

- 实现请求缓存
- 使用连接池
- 压缩响应数据

### 4. 渲染优化

- 使用 `const` 构造函数
- 避免在 build 中做复杂计算
- 使用 `ListView.builder` 懒加载

---

## 🤝 贡献指南

欢迎贡献代码！

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 📞 支持

如有问题，请查看：

- 📖 [Flutter 官方文档](https://flutter.dev/docs)
- 📖 [Dart 语言指南](https://dart.dev/guides)
- 📖 [项目主 README](../../README.md)
- 📖 [API 文档](../../API_USAGE.md)
- 💬 [GitHub Issues](https://github.com/your-username/weather-cli/issues)

---

## 📄 许可证

MIT License

---

**祝你开发愉快！** 🎉
