# Weather CLI 移动端应用启动脚本
# 功能：检查 Flutter 是否安装，如果未安装则提示用户

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Weather CLI 移动端应用启动器" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 步骤 1: 检查 Flutter 是否安装
Write-Host "🔍 检查 Flutter 安装状态..." -ForegroundColor Yellow

try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Flutter 已安装" -ForegroundColor Green
        Write-Host ""
        
        # 显示 Flutter 版本信息
        $flutterVersion | Select-Object -First 1 | ForEach-Object {
            Write-Host "   $_" -ForegroundColor Gray
        }
    } else {
        throw "Flutter not found"
    }
} catch {
    Write-Host "❌ Flutter 未安装或不在 PATH 中" -ForegroundColor Red
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host "⚠️  需要先安装 Flutter 才能运行此应用" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 安装步骤:" -ForegroundColor Cyan
    Write-Host "  1. 访问: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Gray
    Write-Host "  2. 下载并解压 Flutter SDK 到 C:\src\flutter" -ForegroundColor Gray
    Write-Host "  3. 添加 C:\src\flutter\bin 到系统 PATH" -ForegroundColor Gray
    Write-Host "  4. 关闭并重新打开终端" -ForegroundColor Gray
    Write-Host "  5. 运行: flutter doctor" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 详细指南: mobile\FLUTTER_INSTALL_GUIDE.md" -ForegroundColor Cyan
    Write-Host ""
    
    $install = Read-Host "是否现在查看安装指南？(y/n)"
    if ($install -eq "y" -or $install -eq "Y") {
        Start-Process "notepad.exe" "mobile\FLUTTER_INSTALL_GUIDE.md"
    }
    
    exit 1
}

# 步骤 2: 检查项目目录
Write-Host ""
Write-Host "📂 检查项目文件..." -ForegroundColor Yellow

$appDir = "mobile\weather_app"
if (-not (Test-Path $appDir)) {
    Write-Host "❌ 找不到移动端项目目录: $appDir" -ForegroundColor Red
    exit 1
}

Write-Host "✅ 项目目录存在" -ForegroundColor Green

# 步骤 3: 检查依赖
Write-Host ""
Write-Host "📦 检查 Flutter 依赖..." -ForegroundColor Yellow

Set-Location $appDir

if (-not (Test-Path ".packages") -and -not (Test-Path ".dart_tool")) {
    Write-Host "⚠️  依赖未安装，正在安装..." -ForegroundColor Yellow
    flutter pub get
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 依赖安装失败" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ 依赖安装成功" -ForegroundColor Green
} else {
    Write-Host "✅ 依赖已安装" -ForegroundColor Green
}

# 步骤 4: 检查可用设备
Write-Host ""
Write-Host "📱 检查可用设备..." -ForegroundColor Yellow

$devices = flutter devices 2>&1
Write-Host $devices -ForegroundColor Gray

if ($devices -match "No devices detected") {
    Write-Host ""
    Write-Host "⚠️  未检测到可用设备" -ForegroundColor Yellow
    Write-Host "💡 请执行以下操作之一:" -ForegroundColor Cyan
    Write-Host "  - 启动 Android 模拟器" -ForegroundColor Gray
    Write-Host "  - 连接 Android 真机（启用 USB 调试）" -ForegroundColor Gray
    Write-Host "  - 启用 Chrome（Web 开发）: flutter config --enable-web" -ForegroundColor Gray
    Write-Host ""
    
    $continue = Read-Host "是否继续尝试运行？(y/n)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        exit 0
    }
}

# 步骤 5: 提示配置 API 地址
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "⚙️  重要提示：配置 API 地址" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "编辑文件: lib\services\weather_service.dart" -ForegroundColor Yellow
Write-Host ""
Write-Host "根据你的运行环境修改 baseUrl:" -ForegroundColor Gray
Write-Host "  - Android 模拟器: http://10.0.2.2:8080/api" -ForegroundColor Gray
Write-Host "  - iOS 模拟器:     http://localhost:8080/api" -ForegroundColor Gray
Write-Host "  - 真机测试:       http://你的电脑IP:8080/api" -ForegroundColor Gray
Write-Host "  - 生产环境:       https://api.yourdomain.com/api" -ForegroundColor Gray
Write-Host ""

$configured = Read-Host "是否已配置 API 地址？(y/n)"
if ($configured -ne "y" -and $configured -ne "Y") {
    Write-Host ""
    Write-Host "💡 查看详细配置指南: mobile\QUICK_START.md" -ForegroundColor Cyan
    Write-Host ""
    
    $openGuide = Read-Host "是否现在打开配置指南？(y/n)"
    if ($openGuide -eq "y" -or $openGuide -eq "Y") {
        Start-Process "notepad.exe" "QUICK_START.md"
    }
    
    exit 0
}

# 步骤 6: 启动应用
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  🚀 启动 Weather App" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

flutter run

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ 应用启动失败" -ForegroundColor Red
    Write-Host "💡 查看错误信息并修复问题后重试" -ForegroundColor Yellow
    exit 1
}
