# Weather App - Flutter 移动端应用 📱

一个美观的跨平台天气查询移动应用，支持 iOS 和 Android。

## 📋 功能特性

- ✅ 实时天气查询
- ✅ 城市搜索功能
- ✅ 最近搜索记录
- ✅ 下拉刷新
- ✅ 精美的 UI 设计
- ✅ 深色模式支持
- ✅ 详细的天气信息展示

## 🚀 快速开始

### 前置要求

1. **安装 Flutter SDK**
   ```bash
   # 下载 Flutter: https://flutter.dev/docs/get-started/install
   # 验证安装
   flutter doctor
   ```

2. **启动 Weather API 服务**
   
   确保你的 Weather API 服务正在运行：
   
   ```bash
   # 方式 1: 本地运行
   cd ../..
   make run-api
   
   # 方式 2: Docker 运行
   docker run -d -p 8080:8080 -e APP_MODE=api weather-cli:latest
   ```

### 配置 API 地址

编辑 `lib/services/weather_service.dart`，修改 `baseUrl`：

```dart
// 本地开发（Android 模拟器）
static const String baseUrl = 'http://10.0.2.2:8080/api';

// 本地开发（iOS 模拟器）
static const String baseUrl = 'http://localhost:8080/api';

// 生产环境（服务器公网 IP 或域名）
static const String baseUrl = 'http://your-server-ip:8080/api';
// 或使用 HTTPS
static const String baseUrl = 'https://api.yourdomain.com/api';
```

**重要提示：**
- Android 模拟器访问宿主机使用 `10.0.2.2`
- iOS 模拟器访问宿主机使用 `localhost`
- 真机测试需要使用服务器的公网 IP

### 安装依赖

```bash
cd mobile/weather_app
flutter pub get
```

### 运行应用

#### 方式 1: 使用模拟器

```bash
# 启动 Android 模拟器
flutter emulators --launch <emulator_id>

# 启动 iOS 模拟器（macOS）
open -a Simulator

# 运行应用
flutter run
```

#### 方式 2: 连接真机

```bash
# 查看已连接设备
flutter devices

# 运行到指定设备
flutter run -d <device_id>
```

#### 方式 3: 编译安装包

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (需要 macOS)
flutter build ios --release
```

## 📁 项目结构

```
weather_app/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── models/
│   │   └── weather_model.dart       # 数据模型
│   ├── services/
│   │   └── weather_service.dart     # API 服务
│   ├── providers/
│   │   └── weather_provider.dart    # 状态管理
│   ├── screens/
│   │   └── home_screen.dart         # 主页面
│   └── widgets/
│       ├── weather_card.dart        # 天气卡片
│       └── search_dialog.dart       # 搜索对话框
├── pubspec.yaml                     # 依赖配置
└── README.md                        # 本文档
```

## 🎨 界面预览

### 主要功能

1. **首页**
   - 显示当前城市天气
   - 温度、天气状况、风向风力
   - 湿度、能见度、降水量等详细信息

2. **搜索功能**
   - 输入城市名称搜索
   - 显示最近搜索记录
   - 快速切换城市

3. **刷新功能**
   - 下拉刷新最新数据
   - 右上角刷新按钮

## 🔧 自定义配置

### 修改主题颜色

编辑 `lib/main.dart`：

```dart
theme: ThemeData(
  primarySwatch: Colors.blue,  // 修改为主色调
  // ...
),
```

### 添加更多城市快捷方式

编辑 `lib/widgets/search_dialog.dart`：

```dart
final List<String> _recentCities = [
  '北京', '上海', '广州', '深圳', 
  '杭州', '成都', '武汉', '西安'  // 添加更多城市
];
```

### 修改 API 超时时间

编辑 `lib/services/weather_service.dart`：

```dart
.timeout(const Duration(seconds: 15));  // 修改超时时间
```

## 🐛 常见问题

### Q1: 无法连接到 API 服务

**解决方案：**
1. 确认 API 服务正在运行
2. 检查 `baseUrl` 配置是否正确
3. Android 模拟器使用 `10.0.2.2` 而非 `localhost`
4. 检查防火墙是否开放端口

### Q2: 中文显示乱码

**解决方案：**
确保文件编码为 UTF-8，并在 `pubspec.yaml` 中配置字体支持。

### Q3: 构建失败

**解决方案：**
```bash
# 清理缓存
flutter clean

# 重新获取依赖
flutter pub get

# 重新构建
flutter build apk
```

### Q4: iOS 构建失败

**解决方案：**
```bash
cd ios
pod install
cd ..
flutter build ios
```

## 📱 网络配置

### Android 允许明文 HTTP

如果需要访问 HTTP（非 HTTPS）API，在 `android/app/src/main/AndroidManifest.xml` 添加：

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### iOS 允许明文 HTTP

在 `ios/Runner/Info.plist` 添加：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🚀 发布到应用商店

### Android

1. 生成签名密钥
2. 配置 `android/key.properties`
3. 构建 Release 版本
4. 上传到 Google Play

### iOS

1. 配置 Apple Developer 账号
2. 在 Xcode 中配置签名
3. 构建 Archive
4. 上传到 App Store Connect

详细指南：https://flutter.dev/docs/deployment

## 📊 性能优化建议

1. **图片资源**: 使用 WebP 格式减小体积
2. **网络请求**: 实现缓存机制减少重复请求
3. **列表渲染**: 使用 ListView.builder 懒加载
4. **状态管理**: 避免不必要的 rebuild

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 📞 支持

如有问题，请查看：
- [Flutter 官方文档](https://flutter.dev/docs)
- [项目主 README](../../README.md)
- [API 使用文档](../../API_USAGE.md)
