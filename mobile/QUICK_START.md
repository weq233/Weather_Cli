实时天气查询# 📱 移动端应用快速开始

Weather CLI 的 Flutter 跨平台移动应用，支持 iOS 和 Android。

---

## ✨ 功能特性

- ✅ 实时天气查询
- ✅ 城市搜索功能
- ✅ 最近搜索记录
- ✅ 下拉刷新
- ✅ Material Design 3 UI
- ✅ 深色模式支持
- ✅ 详细天气信息展示

---

## 🚀 5 分钟快速上手

### ⚠️ 前置要求

#### 1. 磁盘空间检查

**确保至少预留 10 GB 可用空间：**

| 组件 | 所需空间 |
|------|---------|
| Flutter SDK | ~1 GB |
| Android SDK | ~5 GB |
| 项目依赖 | ~500 MB |
| 构建缓存 | ~2 GB |
| **总计** | **建议 10 GB** |

```powershell
# 检查磁盘空间
Get-PSDrive C | Select-Object Used,Free
```

#### 2. 安装 Flutter SDK

如果尚未安装 Flutter，请先查看：
- 📘 [Flutter 安装指南](FLUTTER_INSTALL_GUIDE.md)

**验证安装：**
```bash
flutter --version
flutter doctor
```

#### 3. 配置 API 地址

编辑 `lib/services/weather_service.dart`，修改 `baseUrl`：

```dart
// Android 模拟器
static const String baseUrl = 'http://10.0.2.2:8080/api';

// iOS 模拟器
static const String baseUrl = 'http://localhost:8080/api';

// 真机测试（替换为你的电脑 IP）
static const String baseUrl = 'http://192.168.1.100:8080/api';
```

⚠️ **注意**: 确保 API 服务正在运行，并且 config.json 中已正确配置 `api.host` 和 `api.key`。

#### 4. 启动 API 服务

```
# 编译并启动 API
go build -o weather-api.exe ./api
./weather-api.exe
   
# 或使用 Docker
docker run -p 8080:8080 weather-cli:latest
```

---

### 步骤 1: 配置 API 地址

编辑 `mobile/weather_app/lib/services/weather_service.dart`:

```
// 根据你的运行环境修改 baseUrl

// Android 模拟器
static const String baseUrl = 'http://10.0.2.2:8080/api';

// iOS 模拟器
static const String baseUrl = 'http://localhost:8080/api';

// 真机测试（替换为你的电脑 IP）
static const String baseUrl = 'http://192.168.1.100:8080/api';

// 生产环境（服务器域名）
static const String baseUrl = 'https://api.yourdomain.com/api';
```

---

### 步骤 2: 安装依赖

```bash
cd mobile/weather_app
flutter pub get
```

---

### 步骤 3: 运行应用

**方式 1: 命令行**
```bash
# 查看可用设备
flutter devices

# 运行到指定设备
flutter run -d <device_id>

# 或直接运行（自动选择）
flutter run
```

**方式 2: VS Code**
1. 打开 `mobile/weather_app` 文件夹
2. 按 `F5` 或点击 "Run" → "Start Debugging"
3. 选择目标设备

**方式 3: 使用快捷脚本**
```bash
# Windows
.\mobile\run-app.ps1

# Linux/Mac
chmod +x mobile/run-app.sh
./mobile/run-app.sh
```

---

## 📱 界面预览

```
┌─────────────────────────┐
│  🌤️ 天气查询      🔍 🔄 │
├─────────────────────────┤
│  📍 北京                 │
│  北京市, 中国            │
├─────────────────────────┤
│     ☀️  15°C            │
│         晴              │
│    🌡️ 体感温度 16°C     │
├─────────────────────────┤
│  💨 风向    💨 风力      │
│  西北风      3级         │
│  💧 湿度    👁️ 能见度   │
│  45%        20km        │
│  🌧️ 降水量  🔽 气压     │
│  0mm        1013hPa     │
├─────────────────────────┤
│  ⏰ 数据更新: 2024-...   │
└─────────────────────────┘
```

---

## 🔧 常用命令

### 开发
```bash
# 热重载（运行中按 r）
# 热重启（运行中按 R）

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

# iOS (macOS)
flutter build ios --release
```

### 清理
```bash
flutter clean
flutter pub get
```

---

## 🐛 常见问题

### Q1: 无法连接到 API

**解决:**
1. 确认 API 服务正在运行
2. 检查 `baseUrl` 配置是否正确
3. Android 模拟器必须使用 `10.0.2.2`
4. 检查防火墙设置

### Q2: Flutter 命令找不到

**解决:**
```bash
# 检查 Flutter 是否安装
flutter --version

# 如果未安装，访问:
# https://flutter.dev/docs/get-started/install
```

### Q3: 构建失败

**解决:**
```bash
flutter clean
flutter pub get
flutter run
```

### Q4: 中文显示乱码

**解决:**
确保文件编码为 UTF-8

---

## 📂 项目结构

```
mobile/weather_app/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── models/                      # 数据模型
│   │   └── weather_model.dart
│   ├── services/                    # API 服务
│   │   └── weather_service.dart
│   ├── providers/                   # 状态管理
│   │   └── weather_provider.dart
│   ├── screens/                     # 页面
│   │   └── home_screen.dart
│   └── widgets/                     # UI 组件
│       ├── weather_card.dart
│       └── search_dialog.dart
├── pubspec.yaml                     # 依赖配置
└── README.md                        # 详细说明
```

---

## 🎨 自定义开发

### 修改主题颜色

编辑 `lib/main.dart`:

```dart
theme: ThemeData(
  primarySwatch: Colors.blue,  // 改为 green, purple, red 等
  useMaterial3: true,
),
```

### 添加新城市快捷方式

编辑 `lib/widgets/search_dialog.dart`:

```dart
final List<String> _recentCities = [
  '北京', '上海', '广州', '深圳', 
  '杭州', '成都', '武汉', '西安'  // 添加更多
];
```

### 修改 API 超时时间

编辑 `lib/services/weather_service.dart`:

```dart
.timeout(const Duration(seconds: 15));  // 修改秒数
```

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

## 📊 技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Flutter | 3.x | 跨平台框架 |
| Dart | 3.x | 编程语言 |
| Provider | 6.x | 状态管理 |
| HTTP | 1.x | 网络请求 |
| Flutter SpinKit | 5.x | 加载动画 |
| Font Awesome | 10.x | 图标库 |

---

## 📖 更多文档

- 📘 [移动端开发完整指南](../MOBILE_DEV_GUIDE.md)
- 📗 [移动端项目总结](../PROJECT_SUMMARY.md)
- 📙 [API 使用文档](../../docs/API_USAGE.md)
- 📕 [配置指南](../../docs/CONFIG_GUIDE.md)

---

## 🎯 下一步

1. ✅ 安装 Flutter SDK
2. ✅ 启动 API 服务
3. ✅ 配置 API 地址
4. ✅ 运行应用
5. 🎉 享受成果！

---

**祝你开发愉快！** 🚀
