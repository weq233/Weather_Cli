# Git 配置指南 🔧

## 📋 配置 Git 用户信息

在使用 Git 之前，需要配置你的用户名和邮箱。

### Windows PowerShell

```powershell
# 配置用户名（替换为你的名字）
git config --global user.name "Your Name"

# 配置邮箱（替换为你的邮箱）
git config --global user.email "your.email@example.com"

# 验证配置
git config --global --list
```

### Git Bash

```bash
# 配置用户名
git config --global user.name "Your Name"

# 配置邮箱
git config --global user.email "your.email@example.com"

# 验证配置
git config --global --list
```

---

## 🚀 初始化 Git 仓库（如果还没有）

```powershell
# 进入项目目录
cd C:\Users\weq233\Desktop\code\Weather_Cli

# 初始化 Git 仓库（如果还没有）
git init

# 添加所有文件
git add .

# 首次提交
git commit -m "Initial commit: Weather CLI with API and Mobile support"
```

---

## 📦 常用 Git 命令

### 查看状态
```powershell
git status
```

### 添加文件
```powershell
# 添加所有更改
git add .

# 添加特定文件
git add README.md
git add cmd/main.go
```

### 提交更改
```powershell
git commit -m "描述你的更改"
```

### 查看历史
```powershell
# 查看提交历史
git log

# 简洁视图
git log --oneline
```

### 创建标签
```powershell
# 创建版本标签
git tag v1.0.0

# 推送标签到远程（如果配置了远程仓库）
git push origin v1.0.0
```

---

## 🌐 连接远程仓库（可选）

如果你有 GitHub/GitLab/Gitee 账号，可以推送代码到远程仓库。

### 添加远程仓库

```powershell
# GitHub 示例
git remote add origin https://github.com/your-username/weather-cli.git

# Gitee 示例
git remote add origin https://gitee.com/your-username/weather-cli.git

# GitLab 示例
git remote add origin https://gitlab.com/your-username/weather-cli.git
```

### 推送代码

```powershell
# 推送到远程
git push -u origin main

# 或 master 分支
git push -u origin master
```

---

## 🔑 SSH 密钥配置（推荐用于远程仓库）

### 生成 SSH 密钥

```powershell
# 生成密钥（使用你的邮箱）
ssh-keygen -t ed25519 -C "your.email@example.com"

# 按提示操作：
# 1. 文件位置：直接回车（使用默认位置）
# 2. 密码短语：直接回车（不设置密码）
```

### 查看公钥

```powershell
cat ~/.ssh/id_ed25519.pub
```

复制输出的内容。

### 添加到 GitHub/Gitee/GitLab

1. **GitHub**: Settings → SSH and GPG keys → New SSH key
2. **Gitee**: 设置 → SSH 公钥 → 添加公钥
3. **GitLab**: Preferences → SSH Keys → Add new key

粘贴公钥并保存。

### 使用 SSH 地址

```powershell
# 如果使用 SSH 而非 HTTPS
git remote set-url origin git@github.com:your-username/weather-cli.git
```

---

## 📝 .gitignore 配置

项目已包含 `.gitignore` 文件，会自动忽略：

- 编译产物（*.exe, build/）
- 依赖目录（vendor/）
- IDE 配置（.vscode/, .idea/）
- 系统文件（Thumbs.db, .DS_Store）
- 敏感信息（config.json 中的密钥建议不要提交）

**注意**: `config.json` 已在版本控制中，但建议：

1. 创建 `config.json.example` 作为模板
2. 将真实的 `config.json` 添加到 `.gitignore`
3. 在部署时手动上传配置文件

---

## 🔄 典型工作流程

### 日常开发

```powershell
# 1. 查看更改
git status

# 2. 添加更改
git add .

# 3. 提交
git commit -m "feat: add new weather endpoint"

# 4. 推送到远程（如果配置了）
git push
```

### 更新部署

```powershell
# 1. 提交最新代码
git add .
git commit -m "update: fix api bug"
git push

# 2. 编译
go build -ldflags="-w -s" -o weather-api.exe ./cmd/api

# 3. 打包
Compress-Archive -Path weather-api.exe,config.json,Dockerfile,docker-compose.yml,Makefile,.dockerignore -DestinationPath deploy.zip -Force

# 4. 上传到服务器
scp deploy.zip root@YOUR_SERVER_IP:/opt/weather-cli/

# 5. SSH 到服务器部署
ssh root@YOUR_SERVER_IP
cd /opt/weather-cli
unzip -o deploy.zip
docker build -t weather-cli:latest .
docker-compose up -d
```

---

## 🐛 常见问题

### Q1: 如何撤销未提交的更改？

```powershell
# 撤销工作区的更改
git checkout -- filename

# 撤销所有未提交的更改
git reset --hard HEAD
```

⚠️ **警告**: 这会永久删除未提交的更改！

### Q2: 如何撤销最后一次提交？

```powershell
# 撤销提交但保留更改
git reset --soft HEAD~1

# 撤销提交并删除更改
git reset --hard HEAD~1
```

### Q3: 如何查看某个文件的修改历史？

```powershell
git log --follow -- filename
git blame filename
```

### Q4: 如何合并冲突？

```powershell
# 1. 拉取最新代码
git pull

# 2. 如果有冲突，编辑冲突文件
# 搜索 <<<<<<<, =======, >>>>>>> 标记

# 3. 解决冲突后
git add .
git commit -m "resolve merge conflict"
```

---

## 💡 最佳实践

### 1. 提交信息规范

使用有意义的提交信息：

```
feat: add new feature
fix: fix a bug
docs: update documentation
style: code style changes
refactor: code refactoring
test: add or update tests
chore: maintenance tasks
```

### 2. 频繁提交

- 小步提交，每次提交一个逻辑单元
- 提交前确保代码可以编译通过
- 提交信息清晰描述更改内容

### 3. 分支管理（进阶）

```powershell
# 创建新功能分支
git checkout -b feature/new-endpoint

# 开发完成后合并到主分支
git checkout main
git merge feature/new-endpoint

# 删除功能分支
git branch -d feature/new-endpoint
```

### 4. 定期备份

- 推送到远程仓库
- 或使用 `git bundle` 创建离线备份

```powershell
git bundle create backup.bundle --all
```

---

## 📚 学习资源

- [Git 官方文档](https://git-scm.com/doc)
- [Pro Git 书籍（免费）](https://git-scm.com/book/zh/v2)
- [GitHub 入门指南](https://docs.github.com/en/get-started)
- [Gitee 帮助文档](https://help.gitee.com/)

---

## 🎯 下一步

配置完 Git 后，你可以：

1. ✅ 开始版本控制
2. ✅ 追踪代码变更
3. ✅ 协作开发
4. ✅ 回滚错误更改
5. ✅ 部署到服务器

**祝你使用愉快！** 🚀
