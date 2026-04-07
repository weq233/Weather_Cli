# 配置文件使用指南 ⚙️

## 🚀 快速开始（3 步配置）

### 步骤 1: 创建配置文件

**Windows:**
```powershell
notepad config.json
```

**Linux/Mac:**
```bash
nano config.json
```

### 步骤 2: 填入配置

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

### 步骤 3: 获取 Host 和 Key

1. 访问 https://console.qweather.com/
2. 注册/登录 → 创建项目
3. 复制 **Host** 和 **Key** 到配置文件

### 验证配置

```bash
# 测试 CLI
./weather-cli.exe --city 北京

# 测试 API
./weather-api.exe
curl http://localhost:8080/api/health
```

---

## 📋 配置项详解

### API 配置（和风天气）

| 字段 | 类型 | 默认值 | 说明 | 是否必填 |
|------|------|--------|------|----------|
| `api.host` | string | - | **API 主机地址** ⚠️ 必须修改 | ✅ 是 |
| `api.key` | string | - | **API 密钥** ⚠️ 必须修改 | ✅ 是 |
| `api.timeout` | int | `10` | API 请求超时时间（秒） | ❌ 否 |

**如何获取 API Host 和 Key：**

#### 步骤 1: 注册和风天气账号

访问 [和风天气控制台](https://console.qweather.com/) 并注册/登录。

#### 步骤 2: 创建项目

1. 点击"创建项目"
2. 填写项目名称（如 "Weather CLI"）
3. 选择项目类型（Web API）
4. 点击"创建"

#### 步骤 3: 获取 Host 和 Key

在项目详情页面找到：

- **Host**: 类似 ``
- **Key**: 类似 ``

**复制这两个值到配置文件：**

```json
{
  "api": {
    "host": "你的Host（从控制台复制）",
    "key": "你的Key（从控制台复制）",
    "timeout": 10
  }
}
```

⚠️ **注意**: 
- Host 和 Key **都是唯一的**，每个项目不同
- **不要使用示例中的值**，必须使用你自己的
- Key 是敏感信息，不要公开分享

---

### 服务器配置（API 服务）

| 配置项 | 说明 | 默认值 | 备注 |
|--------|------|--------|------|
| `server.port` | API 服务端口 | `8080` | 确保端口未被占用 |
| `server.mode` | 运行模式 | `release` | `debug`/`release`/`test` |

---

## 💡 使用示例

### 示例 1: 本地开发（使用 Demo Key）

```json
{
  "api": {
    "host": "host",
    "key": "key",
    "timeout": 10
  },
  "server": {
    "port": 8080,
    "mode": "debug"
  }
}
```

### 示例 2: 生产环境

```json
{
  "api": {
    "host": "your-production-host.qweatherapi.com",
    "key": "your-real-api-key",
    "timeout": 5
  },
  "server": {
    "port": 8080,
    "mode": "release"
  }
}
```

### 示例 3: 自定义端口

```json
{
  "api": {
    "host": "your-api-host",
    "key": "your-api-key",
    "timeout": 10
  },
  "server": {
    "port": 3000,
    "mode": "release"
  }
}
```

---

## 🔄 配置优先级

配置的加载遵循以下优先级（从高到低）：

### API Key
1. 命令行参数: `--api-key YOUR_KEY`
2. 环境变量: `WEATHER_API_KEY`
3. 配置文件: `api.key` ✨
4. 默认值: demo key

### API Host
1. 环境变量: `WEATHER_API_HOST`
2. 配置文件: `api.host` ✨
3. 默认值: ''

### 服务器端口
1. 环境变量: `SERVER_PORT`
2. 配置文件: `server.port` ✨
3. 默认值: 8080

---

## 🚀 验证配置

### 测试 CLI

```bash
# 使用配置文件
./weather-cli.exe --city 北京

# 或指定 API Key（会覆盖配置文件）
./weather-cli.exe --city 北京 --api-key your-key
```

### 测试 API 服务

```bash
# 启动 API 服务
./weather-api.exe

# 在另一个终端测试
curl http://localhost:8080/api/health
curl "http://localhost:8080/api/weather?city=北京"
```

---

## 🔒 安全提示

### ⚠️ 不要将 API Key 提交到 Git！

`.gitignore` 已配置忽略 `config.json`，但请确认：

```bash
# 检查 config.json 是否被忽略
git check-ignore config.json

# 应该输出: config.json
```

如果未忽略，手动添加：

```bash
echo "config.json" >> .gitignore
git add .gitignore
git commit -m "ignore config.json"
```

### ✅ 推荐做法

1. **开发环境**: 使用 `config.json`（不提交到 Git）
2. **生产环境**: 使用环境变量或 Docker secrets

```bash
# Linux
export WEATHER_API_KEY="your-key"
export WEATHER_API_HOST="your-host"

# Windows PowerShell
$env:WEATHER_API_KEY="your-key"
$env:WEATHER_API_HOST="your-host"
```

---

## 🐛 常见问题

### Q1: 配置文件在哪里？

程序会在以下位置查找：
1. 当前工作目录: `./config.json`
2. 可执行文件所在目录: `<exe_dir>/config.json`

### Q2: 修改配置后需要重启吗？

- **CLI**: 每次运行都会重新读取配置
- **API 服务**: 需要重启服务才能生效

```bash
# 重启 API 服务
Ctrl+C 停止
./weather-api.exe 重新启动
```

### Q3: 配置格式错误怎么办？

使用 JSON 验证工具检查：

```bash
# Windows PowerShell
Get-Content config.json | ConvertFrom-Json

# Linux/Mac
cat config.json | python3 -m json.tool
```

### Q4: 没有 API Key 能用吗？

可以！使用 `"key": "demo"` 会返回模拟数据，适合测试。

---

## 📚 相关文档

- [部署指南](DEPLOY_GUIDE.md)
- [API 使用文档](API_USAGE.md)
- [快速开始](QUICKSTART.md)

---

**配置完成！开始使用吧！** 🎉
