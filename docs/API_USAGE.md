# Weather API 使用文档

## 📖 概述

Weather API 是基于 Go + Gin 框架构建的 RESTful API 服务，提供和风天气数据查询功能。支持跨域访问（CORS），可直接被移动端应用调用。

## 🚀 快速开始

### 1. 本地运行 API 服务

```bash
# 方式 1: 使用 Makefile
make run-api

# 方式 2: 直接运行
go run cmd/api/main.go

# 方式 3: Docker 运行
make docker-run-api
```

### 2. 验证服务

```bash
curl http://localhost:8080/api/health
```

预期响应：
```json
{
  "success": true,
  "message": "Service is running"
}
```

## 📡 API 接口文档

### 基础信息

- **Base URL**: `http://localhost:8080`
- **Content-Type**: `application/json`
- **字符编码**: `UTF-8`

### 接口列表

#### 1. 健康检查

**请求**
```
GET /api/health
```

**响应示例**
```json
{
  "success": true,
  "message": "Service is running"
}
```

---

#### 2. 查询天气

**请求**
```
GET /api/weather?city=北京
```

**参数说明**

| 参数名 | 类型   | 必填 | 说明     | 示例   |
|--------|--------|------|----------|--------|
| city   | string | 是   | 城市名称 | 北京   |

**成功响应 (200)**
```json
{
  "success": true,
  "data": {
    "city": "北京",
    "province": "北京市",
    "country": "中国",
    "location_id": "101010100",
    "weather": {
      "obsTime": "2024-01-15T14:30",
      "temp": "5",
      "feelsLike": "2",
      "icon": "100",
      "text": "晴",
      "wind360": "315",
      "windDir": "西北风",
      "windScale": "3",
      "windSpeed": "15",
      "humidity": "30",
      "precip": "0",
      "pressure": "1020",
      "vis": "25",
      "cloud": "0",
      "dew": "-10"
    },
    "update_time": "2024-01-15T14:30+08:00"
  }
}
```

**失败响应 (400/500)**
```json
{
  "success": false,
  "message": "错误信息描述"
}
```

---

#### 3. 获取版本信息

**请求**
```
GET /api/version
```

**响应示例**
```json
{
  "success": true,
  "data": {
    "name": "Weather API",
    "version": "1.0.0"
  }
}
```

---

## 🌐 CORS 支持

API 已配置 CORS 中间件，允许所有来源的跨域请求：

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

## 🔧 配置说明

### 环境变量

| 变量名       | 默认值        | 说明              |
|--------------|---------------|-------------------|
| API_PORT     | 8080          | API 服务端口      |
| GIN_MODE     | release       | Gin 运行模式      |
| WEATHER_API_KEY | (从配置文件读取) | 和风天气 API Key |
| WEATHER_API_HOST | (从配置文件读取) | API Host        |
| TZ           | Asia/Shanghai | 时区              |

### 配置文件

确保 `config.json` 存在并配置正确的 API Key：

```json
{
  "api_host": "your_api_host_here",
  "api_key": "your_api_key_here",
  "timeout": 10
}
```

## 📱 移动端调用示例

### Flutter (Dart)

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> getWeather(String city) async {
  final response = await http.get(
    Uri.parse('http://your-server:8080/api/weather?city=$city'),
  );

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load weather');
  }
}
```

### React Native (JavaScript)

```javascript
const getWeather = async (city) => {
  try {
    const response = await fetch(
      `http://your-server:8080/api/weather?city=${city}`
    );
    const data = await response.json();
    
    if (data.success) {
      return data.data;
    } else {
      throw new Error(data.message);
    }
  } catch (error) {
    console.error('Error:', error);
  }
};
```

### iOS (Swift)

```swift
import Foundation

func getWeather(city: String, completion: @escaping (Result<Data, Error>) -> Void) {
    let url = URL(string: "http://your-server:8080/api/weather?city=\(city)")!
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: 0)))
            return
        }
        
        completion(.success(data))
    }.resume()
}
```

### Android (Kotlin)

```kotlin
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.IOException

fun getWeather(city: String, callback: (String?) -> Unit) {
    val client = OkHttpClient()
    val request = Request.Builder()
        .url("http://your-server:8080/api/weather?city=$city")
        .build()

    client.newCall(request).enqueue(object : okhttp3.Callback {
        override fun onFailure(call: okhttp3.Call, e: IOException) {
            callback(null)
        }

        override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
            callback(response.body?.string())
        }
    })
}
```

## 🐳 Docker 部署

### 单独运行 API

```bash
docker run -d \
  --name weather-api \
  -p 8080:8080 \
  -e APP_MODE=api \
  -v $(pwd)/config.json:/app/config.json:ro \
  weather-cli:latest
```

### 使用 Docker Compose

```bash
docker-compose up -d weather-api
```

## 🔍 测试命令

```bash
# 健康检查
curl http://localhost:8080/api/health

# 查询北京天气
curl "http://localhost:8080/api/weather?city=北京"

# 查询上海天气
curl "http://localhost:8080/api/weather?city=Shanghai"

# 获取版本信息
curl http://localhost:8080/api/version
```

## 📊 响应数据结构

### WeatherResult 字段说明

| 字段         | 类型   | 说明           |
|--------------|--------|----------------|
| city         | string | 城市名称       |
| province     | string | 省份/行政区    |
| country      | string | 国家           |
| location_id  | string | 城市 ID        |
| weather      | object | 天气数据对象   |
| update_time  | string | 数据更新时间   |

### Weather 字段说明

| 字段      | 类型   | 说明     |
|-----------|--------|----------|
| obsTime   | string | 观测时间 |
| temp      | string | 温度     |
| feelsLike | string | 体感温度 |
| text      | string | 天气状况 |
| windDir   | string | 风向     |
| windScale | string | 风力等级 |
| humidity  | string | 湿度     |
| vis       | string | 能见度   |
| precip    | string | 降水量   |
| pressure  | string | 气压     |

## ⚠️ 注意事项

1. **API Key 安全**: 不要将 API Key 暴露在客户端代码中，应通过后端代理
2. **速率限制**: 和风天气免费版每日限额 1000 次调用
3. **网络超时**: 默认超时时间为 10 秒，可通过配置文件调整
4. **错误处理**: 所有错误都会返回 `success: false` 和错误消息

## 🛠️ 开发指南

### 添加新接口

1. 在 `api/handlers.go` 中添加处理方法
2. 在 `api/routes.go` 中注册路由
3. 更新本文档

### 修改端口

```bash
export API_PORT=3000
make run-api
```

### 调试模式

```bash
export GIN_MODE=debug
make run-api
```

## 📞 支持

如有问题，请查看：
- 项目 README.md
- GitHub Issues
- 和风天气官方文档: https://dev.qweather.com/
