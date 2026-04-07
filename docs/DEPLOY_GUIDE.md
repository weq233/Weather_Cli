# 手动部署指南 📦

从 Windows 打包上传到 Linux 服务器并容器化部署。

---

## 📋 前置要求

### Windows 端
- ✅ Git 已安装
- ✅ Go 环境已配置
- ✅ SSH 客户端可用（Windows 10/11 自带）

### Linux 服务器端
- ✅ Docker 已安装
- ✅ Docker Compose 已安装
- ✅ SSH 服务运行中

---

## 🚀 部署步骤

### 步骤 1: Windows 端编译项目

```powershell
# 进入项目目录
cd C:\Users\weq233\Desktop\code\Weather_Cli

# 编译 CLI（可选，用于本地测试）
go build -ldflags="-w -s" -o weather-cli.exe ./cmd

# 编译 API（必须）
go build -ldflags="-w -s" -o weather-api.exe ./cmd/api
```

---

### 步骤 2: 创建部署包

**方式 A: 使用 PowerShell 压缩**

```powershell
# 创建部署文件列表
$files = @(
    "weather-api.exe",
    "config.json",
    "Dockerfile",
    "docker-compose.yml",
    "Makefile",
    ".dockerignore"
)

# 压缩为 zip
Compress-Archive -Path $files -DestinationPath "weather-cli-deploy.zip" -Force
```

**方式 B: 手动打包**

1. 新建文件夹 `deploy`
2. 复制以下文件到该文件夹：
   - `weather-api.exe`
   - `config.json`
   - `Dockerfile`
   - `docker-compose.yml`
   - `Makefile`
   - `.dockerignore`
3. 右键 → 发送到 → 压缩(zipped)文件夹

---

### 步骤 3: 上传到 Linux 服务器

```powershell
# 替换为你的服务器信息
$ServerIP = "your-server-ip"      # 例如: 192.168.1.100
$ServerUser = "root"               # SSH 用户名
$RemotePath = "/opt/weather-cli"   # 远程部署路径

# 创建远程目录
ssh ${ServerUser}@${ServerIP} "mkdir -p ${RemotePath}"

# 上传文件
scp weather-cli-deploy.zip ${ServerUser}@${ServerIP}:${RemotePath}/
```

**如果使用密钥登录：**
```powershell
# 指定私钥文件
scp -i ~/.ssh/id_rsa weather-cli-deploy.zip ${ServerUser}@${ServerIP}:${RemotePath}/
```

---

### 步骤 4: SSH 登录到服务器

```bash
# 登录服务器
ssh root@your-server-ip

# 进入部署目录
cd /opt/weather-cli
```

---

### 步骤 5: 解压并部署

```bash
# 解压部署包
unzip weather-cli-deploy.zip

# 或者使用 tar（如果是 .tar.gz）
# tar -xzf weather-cli-deploy.tar.gz

# 设置执行权限
chmod +x weather-api.exe
```

---

### 步骤 6: 构建 Docker 镜像

```bash
# 在 /opt/weather-cli 目录下
cd /opt/weather-cli

# 构建镜像
docker build -t weather-cli:latest .

# 查看镜像
docker images | grep weather-cli
```

---

### 步骤 7: 启动容器

```bash
# 使用 docker-compose 启动
docker-compose up -d

# 或直接使用 docker run
docker run -d \
  --name weather-api \
  -p 8080:8080 \
  -e APP_MODE=api \
  -e TZ=Asia/Shanghai \
  -v $(pwd)/config.json:/app/config.json:ro \
  --restart unless-stopped \
  weather-cli:latest
```

---

### 步骤 8: 验证部署

```bash
# 检查容器状态
docker ps | grep weather

# 查看日志
docker logs -f weather-api

# 测试 API
curl http://localhost:8080/api/health
curl "http://localhost:8080/api/weather?city=北京"
```

---

## 🔍 常用管理命令

### 查看服务状态
```bash
docker-compose ps
# 或
docker ps | grep weather
```

### 查看日志
```bash
# 实时日志
docker-compose logs -f

# 最近 100 行
docker-compose logs --tail=100

# 特定容器
docker logs -f weather-api
```

### 重启服务
```bash
docker-compose restart
# 或
docker restart weather-api
```

### 停止服务
```bash
docker-compose down
# 或
docker stop weather-api
docker rm weather-api
```

### 更新服务
```bash
# 1. 停止旧容器
docker-compose down

# 2. 上传新文件（从 Windows）
# scp weather-cli-deploy.zip root@server:/opt/weather-cli/

# 3. 解压并重新构建
cd /opt/weather-cli
unzip -o weather-cli-deploy.zip
docker build -t weather-cli:latest .
docker-compose up -d
```

### 清理资源
```bash
# 删除停止的容器
docker container prune

# 删除未使用的镜像
docker image prune

# 删除所有未使用的资源
docker system prune -a
```

---

## 📝 配置文件说明

### config.json

在服务器上编辑配置文件：

```bash
nano /opt/weather-cli/config.json
```

填入你的和风天气 API 信息：

```json
{
  "api_host": "your-api-host.qweatherapi.com",
  "api_key": "your-api-key",
  "timeout": 10
}
```

保存后重启容器：

```bash
docker-compose restart
```

---

### docker-compose.yml

如果需要修改端口或其他配置：

```bash
nano /opt/weather-cli/docker-compose.yml
```

修改后重新构建：

```bash
docker-compose down
docker-compose up -d
```

---

## 🔒 安全建议

### 1. 配置防火墙

```bash
# Ubuntu/Debian (ufw)
ufw allow 8080/tcp
ufw reload

# CentOS/RHEL (firewalld)
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload
```

### 2. 使用 HTTPS（推荐）

安装 Nginx 作为反向代理：

```bash
# 安装 Nginx
apt install nginx -y

# 配置反向代理
nano /etc/nginx/sites-available/weather-api
```

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# 启用配置
ln -s /etc/nginx/sites-available/weather-api /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# 配置 SSL（使用 Let's Encrypt）
apt install certbot python3-certbot-nginx -y
certbot --nginx -d api.yourdomain.com
```

### 3. 限制 Docker 访问

```bash
# 不要将 Docker socket 暴露给外部
# 只允许必要的端口
```

---

## 🐛 故障排查

### 问题 1: 容器无法启动

```bash
# 查看详细日志
docker logs weather-api

# 常见原因：
# - 端口被占用
# - 配置文件错误
# - 权限问题
```

**解决：**
```bash
# 检查端口占用
netstat -tlnp | grep 8080

# 检查配置文件
cat /opt/weather-cli/config.json

# 检查文件权限
ls -la /opt/weather-cli/
```

---

### 问题 2: API 返回错误

```bash
# 检查容器内网络
docker exec -it weather-api ping qweatherapi.com

# 检查 API Key 配置
docker exec -it weather-api cat /app/config.json
```

---

### 问题 3: 磁盘空间不足

```bash
# 检查磁盘使用
df -h

# 清理 Docker 资源
docker system prune -a --volumes

# 清理旧日志
journalctl --vacuum-size=100M
```

---

### 问题 4: 内存不足

```bash
# 检查内存使用
free -h
top

# 限制容器内存
# 编辑 docker-compose.yml，添加：
# deploy:
#   resources:
#     limits:
#       memory: 512M
```

---

## 📊 监控建议

### 1. 设置开机自启

```bash
# Docker Compose 已通过 restart: unless-stopped 配置
# 确保 Docker 服务开机自启
systemctl enable docker
```

### 2. 监控容器状态

```bash
# 创建监控脚本
nano /opt/weather-cli/monitor.sh
```

```bash
#!/bin/bash
CONTAINER="weather-api"

if ! docker ps | grep -q $CONTAINER; then
    echo "⚠️  容器 $CONTAINER 未运行，正在重启..."
    cd /opt/weather-cli
    docker-compose up -d
    echo "✅ 容器已重启" | mail -s "Weather API Alert" admin@example.com
fi
```

```bash
chmod +x monitor.sh

# 添加到 crontab（每 5 分钟检查一次）
crontab -e
*/5 * * * * /opt/weather-cli/monitor.sh
```

### 3. 日志轮转

编辑 `/etc/docker/daemon.json`：

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

```bash
systemctl restart docker
```

---

## 🎯 完整部署流程总结

```
Windows 端                          Linux 服务器端
─────────                          ─────────────

1. 编译项目                        
   go build -o weather-api.exe     
                                   
2. 创建部署包                      
   Compress-Archive                
                                   
3. 上传到服务器                    
   scp deploy.zip user@server:/path
                                   
                                   4. 登录服务器
                                      ssh user@server
                                   
                                   5. 解压文件
                                      unzip deploy.zip
                                   
                                   6. 构建镜像
                                      docker build -t weather-cli:latest .
                                   
                                   7. 启动容器
                                      docker-compose up -d
                                   
                                   8. 验证部署
                                      curl localhost:8080/api/health
```

---

## 💡 提示

1. **首次部署**需要完成所有步骤
2. **更新部署**只需重新上传、解压、重建镜像
3. **配置文件修改**后需要重启容器
4. **定期备份**重要的配置文件和数据
5. **监控日志**及时发现问题

---

## 📞 需要帮助？

- 查看 Docker 文档: https://docs.docker.com/
- 查看 Docker Compose 文档: https://docs.docker.com/compose/
- 查看项目 README: ../README.md

---

**祝你部署顺利！** 🚀
