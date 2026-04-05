# 多阶段构建 - 第一阶段:编译
FROM golang:1.21-alpine AS builder

WORKDIR /app

# 配置国内 Go 模块代理(解决网络超时问题)
ENV GOPROXY=https://goproxy.cn,https://proxy.golang.org,direct
ENV GO111MODULE=on

# 复制依赖文件
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY cmd/ ./cmd/
COPY config.json ./

# 交叉编译为 Linux amd64
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o weather-cli ./cmd

# 第二阶段:运行
FROM alpine:latest

WORKDIR /app

# 安装 ca-certificates(HTTPS 需要)和 shell(调试用)
RUN apk --no-cache add ca-certificates bash

# 从 builder 阶段复制编译好的二进制和配置文件
COPY --from=builder /app/weather-cli .
COPY --from=builder /app/config.json .

# 设置执行权限
RUN chmod +x weather-cli

# 默认命令(可通过 docker run 覆盖)
ENTRYPOINT ["./weather-cli"]
