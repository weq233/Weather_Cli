#!/bin/bash

# Weather CLI 移动端应用启动脚本
# 功能：检查 Flutter 是否安装，如果未安装则提示用户

echo "========================================"
echo "  Weather CLI 移动端应用启动器"
echo "========================================"
echo ""

# 步骤 1: 检查 Flutter 是否安装
echo -e "\033[33m🔍 检查 Flutter 安装状态...\033[0m"

if command -v flutter &> /dev/null; then
    echo -e "\033[32m✅ Flutter 已安装\033[0m"
    echo ""
    
    # 显示 Flutter 版本信息
    flutter --version | head -n 1 | sed 's/^/   /'
else
    echo -e "\033[31m❌ Flutter 未安装或不在 PATH 中\033[0m"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "\033[33m⚠️  需要先安装 Flutter 才能运行此应用\033[0m"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "\033[36m📋 安装步骤:\033[0m"
    echo -e "  \033[90m1. 访问: https://docs.flutter.dev/get-started/install\033[0m"
    echo -e "  \033[90m2. 下载并解压 Flutter SDK\033[0m"
    echo -e "  \033[90m3. 添加 flutter/bin 到 PATH\033[0m"
    echo -e "  \033[90m4. 重新打开终端\033[0m"
    echo -e "  \033[90m5. 运行: flutter doctor\033[0m"
    echo ""
    echo -e "\033[36m💡 详细指南: mobile/FLUTTER_INSTALL_GUIDE.md\033[0m"
    echo ""
    
    read -p "是否现在查看安装指南？(y/n): " install
    if [ "$install" = "y" ] || [ "$install" = "Y" ]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open FLUTTER_INSTALL_GUIDE.md
        elif command -v open &> /dev/null; then
            open FLUTTER_INSTALL_GUIDE.md
        else
            cat FLUTTER_INSTALL_GUIDE.md
        fi
    fi
    
    exit 1
fi

# 步骤 2: 检查项目目录
echo ""
echo -e "\033[33m📂 检查项目文件...\033[0m"

APP_DIR="mobile/weather_app"
if [ ! -d "$APP_DIR" ]; then
    echo -e "\033[31m❌ 找不到移动端项目目录: $APP_DIR\033[0m"
    exit 1
fi

echo -e "\033[32m✅ 项目目录存在\033[0m"

# 步骤 3: 检查依赖
echo ""
echo -e "\033[33m📦 检查 Flutter 依赖...\033[0m"

cd "$APP_DIR" || exit 1

if [ ! -d ".dart_tool" ] && [ ! -f ".packages" ]; then
    echo -e "\033[33m⚠️  依赖未安装，正在安装...\033[0m"
    flutter pub get
    
    if [ $? -ne 0 ]; then
        echo -e "\033[31m❌ 依赖安装失败\033[0m"
        exit 1
    fi
    
    echo -e "\033[32m✅ 依赖安装成功\033[0m"
else
    echo -e "\033[32m✅ 依赖已安装\033[0m"
fi

# 步骤 4: 检查可用设备
echo ""
echo -e "\033[33m📱 检查可用设备...\033[0m"

flutter devices

if flutter devices 2>&1 | grep -q "No devices detected"; then
    echo ""
    echo -e "\033[33m⚠️  未检测到可用设备\033[0m"
    echo -e "\033[36m💡 请执行以下操作之一:\033[0m"
    echo -e "  \033[90m- 启动 Android 模拟器\033[0m"
    echo -e "  \033[90m- 连接 Android 真机（启用 USB 调试）\033[0m"
    echo -e "  \033[90m- 启用 Chrome（Web 开发）: flutter config --enable-web\033[0m"
    echo ""
    
    read -p "是否继续尝试运行？(y/n): " continue_run
    if [ "$continue_run" != "y" ] && [ "$continue_run" != "Y" ]; then
        exit 0
    fi
fi

# 步骤 5: 提示配置 API 地址
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "\033[36m⚙️  重要提示：配置 API 地址\033[0m"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "\033[33m编辑文件: lib/services/weather_service.dart\033[0m"
echo ""
echo -e "\033[90m根据你的运行环境修改 baseUrl:\033[0m"
echo -e "  \033[90m- Android 模拟器: http://10.0.2.2:8080/api\033[0m"
echo -e "  \033[90m- iOS 模拟器:     http://localhost:8080/api\033[0m"
echo -e "  \033[90m- 真机测试:       http://你的电脑IP:8080/api\033[0m"
echo -e "  \033[90m- 生产环境:       https://api.yourdomain.com/api\033[0m"
echo ""

read -p "是否已配置 API 地址？(y/n): " configured
if [ "$configured" != "y" ] && [ "$configured" != "Y" ]; then
    echo ""
    echo -e "\033[36m💡 查看详细配置指南: QUICK_START.md\033[0m"
    echo ""
    
    read -p "是否现在打开配置指南？(y/n): " open_guide
    if [ "$open_guide" = "y" ] || [ "$open_guide" = "Y" ]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open QUICK_START.md
        elif command -v open &> /dev/null; then
            open QUICK_START.md
        else
            cat QUICK_START.md
        fi
    fi
    
    exit 0
fi

# 步骤 6: 启动应用
echo ""
echo "========================================"
echo -e "  \033[32m🚀 启动 Weather App\033[0m"
echo "========================================"
echo ""

flutter run

if [ $? -ne 0 ]; then
    echo ""
    echo -e "\033[31m❌ 应用启动失败\033[0m"
    echo -e "\033[33m💡 查看错误信息并修复问题后重试\033[0m"
    exit 1
fi
