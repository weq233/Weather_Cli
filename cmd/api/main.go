// cmd/api/main.go
package main

import (
	"log"
	"weather-cli/api"
)

func main() {
	// 创建并启动 API 服务器
	server, err := api.NewServer()
	if err != nil {
		log.Fatalf("❌ 启动失败: %v", err)
	}

	if err := server.Start(); err != nil {
		log.Fatalf("❌ 服务运行错误: %v", err)
	}
}
