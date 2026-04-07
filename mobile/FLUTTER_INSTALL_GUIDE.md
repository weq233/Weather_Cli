# Flutter 安装指南 📱

## 🔍 当前状态

❌ **Flutter 未安装**

需要先安装 Flutter SDK 才能运行移动端应用。

---

## 🚀 Windows 安装步骤

### 方法 1: 手动安装（推荐）

#### 步骤 1: 下载 Flutter SDK

访问官方中文下载地址：
- https://docs.flutter.cn/install/manual

或直接下载稳定版 ZIP 文件。

#### 步骤 2: 解压到指定目录

建议解压到：
```
C:\src\flutter
```

**注意：** 不要将 Flutter 安装在需要管理员权限的目录（如 `Program Files`）。

#### 步骤 3: 添加到系统 PATH

**方式 A: 通过图形界面**

1. 按 `Win + X`，选择"系统"
2. 点击"高级系统设置"
3. 点击"环境变量"
4. 在"用户变量"中找到 `Path`
5. 点击"编辑" → "新建"
6. 添加：`C:\src\flutter\bin`
7. 点击"确定"保存

**方式 B: 通过 PowerShell（管理员权限）**

```powershell
# 以管理员身份运行 PowerShell
[Environment]::SetEnvironmentVariable(
    "Path", 
    $env:Path + ";C:\src\flutter\bin", 
    "User"
)
```

**方式 C: 使用命令行（临时生效）**

```powershell
# 仅当前终端会话有效
$env:Path += ";C:\src\flutter\bin"
```

#### 步骤 4: 验证安装

**关闭并重新打开终端**，然后运行：

```bash
flutter --version
```

应该看到类似输出：
```
Flutter 3.x.x • channel stable • ...
Framework • revision ... • ...
Engine • revision ...
Tools • Dart 3.x.x • DevTools 2.x.x
```

---

### 方法 2: 使用 Chocolatey（包管理器）

如果你已安装 [Chocolatey](https://chocolatey.org/)：

```powershell
# 以管理员身份运行 PowerShell
choco install flutter
```

### 磁盘空间要求 ⚠️

**确保至少预留以下空间：**

| 组件 | 所需空间 | 说明 |
|------|---------|------|
| Flutter SDK | ~1 GB | 核心框架和工具 |
| Android SDK | ~5 GB | Android 开发工具和系统镜像 |
| 项目依赖 | ~500 MB | Flutter 包和第三方库 |
| 构建缓存 | ~2 GB | 编译中间文件 |
| **总计** | **建议预留 10 GB** | 确保流畅开发和构建 |

**检查磁盘空间：**
```powershell
# Windows PowerShell
Get-PSDrive C | Select-Object Used,Free

# 或查看属性
# 右键 C: 盘 → 属性
```

**如果空间不足：**
- 清理临时文件：`cleanmgr`（磁盘清理工具）
- 卸载不需要的应用
- 移动其他文件到其他磁盘
- 使用外部存储（不推荐用于 SDK）

---

## 🔧 安装后配置

### 步骤 1: 运行 Flutter Doctor

```bash
flutter doctor
```

这会检查你的开发环境，输出类似：

```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.x.x, on Microsoft Windows ...)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
[✗] Chrome - develop for the web (Cannot find Chrome executable ...)
[!] Connected device (None available)
[✓] Network resources
```

### 步骤 2: 根据需求安装依赖

#### 仅开发 Android 应用

**安装 Android Studio:**

1. 下载: https://developer.android.com/studio
2. 安装时勾选 "Android SDK" 和 "Android Virtual Device"
3. 启动 Android Studio
4. 打开 Settings → Appearance & Behavior → System Settings → Android SDK
5. 安装必要的 SDK 组件

**配置 Android SDK 路径:**

```bash
flutter config --android-sdk <path-to-android-sdk>
```

通常路径为：
```
C:\Users\YourName\AppData\Local\Android\Sdk
```

**接受 Android licenses:**

```bash
flutter doctor --android-licenses
```

#### 仅开发 iOS 应用

⚠️ **注意**: iOS 开发只能在 macOS 上进行！

Windows 用户无法开发 iOS 应用，但可以：
- 开发 Android 应用
- 开发 Web 应用
- 开发 Windows 桌面应用

#### 开发 Web 应用

安装 Chrome 浏览器：
- 下载: https://www.google.com/chrome/

然后启用 Web 支持：

```bash
flutter config --enable-web
```

#### 开发 Windows 桌面应用

启用 Windows 桌面支持：

```bash
flutter config --enable-windows-desktop
```

---

## 📱 设置模拟器/真机

### Android 模拟器

#### 方式 1: 使用 Android Studio

1. 打开 Android Studio
2. Tools → Device Manager
3. Click "Create Device"
4. 选择设备型号（如 Pixel 5）
5. 选择系统镜像（推荐 API 33+）
6. 完成创建
7. 点击 ▶️ 启动模拟器

#### 方式 2: 命令行创建

```bash
# 列出可用系统镜像
flutter emulators

# 创建模拟器
flutter emulators --create --name pixel_5

# 启动模拟器
flutter emulators --launch pixel_5
```

### Android 真机调试

1. **启用开发者选项**
   - 设置 → 关于手机 → 连续点击"版本号"7 次

2. **启用 USB 调试**
   - 设置 → 开发者选项 → USB 调试

3. **连接电脑**
   - 使用 USB 线连接
   - 手机上允许 USB 调试授权

4. **验证连接**
   ```bash
   flutter devices
   ```

---

## ✅ 验证完整安装

运行以下命令确保一切正常：

```bash
# 1. 检查 Flutter 版本
flutter --version

# 2. 检查开发环境
flutter doctor

# 3. 查看可用设备
flutter devices

# 4. 创建测试项目
flutter create test_app
cd test_app
flutter run
```

如果看到模拟器或真机上显示 Flutter 默认应用，说明安装成功！🎉

---

## 🐛 常见问题

### Q1: flutter 命令找不到

**原因**: PATH 未正确配置

**解决**:
1. 确认 Flutter 解压路径正确
2. 重新添加 PATH
3. **关闭并重新打开终端**

### Q2: Flutter doctor 显示警告

**常见警告及解决**:

**Android SDK 未找到:**
```bash
flutter config --android-sdk C:\Users\YourName\AppData\Local\Android\Sdk
```

**Chrome 未找到:**
- 安装 Chrome 浏览器
- 或禁用 Web 支持：`flutter config --no-enable-web`

**没有可用设备:**
- 启动 Android 模拟器
- 或连接真机

### Q3: 构建失败

**解决**:
```bash
# 清理缓存
flutter clean

# 重新获取依赖
flutter pub get

# 重新运行
flutter run
```

### Q4: 网络问题

**原因**: 国内访问 Flutter 服务器较慢

**解决**: 配置镜像

```powershell
# PowerShell
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"

# 永久配置（添加到系统环境变量）
[Environment]::SetEnvironmentVariable("PUB_HOSTED_URL", "https://pub.flutter-io.cn", "User")
[Environment]::SetEnvironmentVariable("FLUTTER_STORAGE_BASE_URL", "https://storage.flutter-io.cn", "User")
```

---

## 📚 学习资源

- [Flutter 官方文档](https://docs.flutter.dev/)
- [Dart 语言教程](https://dart.dev/guides)
- [Flutter 中文社区](https://flutter.cn/)
- [Bilibili Flutter 教程](https://search.bilibili.com/all?keyword=Flutter%20%E6%95%99%E7%A8%8B)

---

## 🎯 下一步

安装完成后：

1. ✅ 运行 `flutter doctor` 确保环境正常
2. ✅ 启动 Android 模拟器或连接真机
3. ✅ 进入项目目录：`cd mobile/weather_app`
4. ✅ 安装依赖：`flutter pub get`
5. ✅ 配置 API 地址（见 QUICK_START.md）
6. ✅ 运行应用：`flutter run`

---

**祝你安装顺利！** 🚀

如有问题，查看：
- [Flutter 故障排查](https://docs.flutter.dev/get-started/install/windows#troubleshooting)
- [项目快速开始](QUICK_START.md)
