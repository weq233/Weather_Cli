// api/server.go
package api

import (
	"fmt"
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"weather-cli/internal/config"
	"weather-cli/internal/weather"
)

// Server API 服务器
type Server struct {
	router *gin.Engine
	port   string
}

// NewServer 创建新的 API 服务器
func NewServer() (*Server, error) {
	// 加载配置
	cfg, err := config.Load()
	if err != nil {
		return nil, fmt.Errorf("加载配置失败: %w", err)
	}

	// 创建天气客户端
	weatherClient := weather.NewClient(cfg)

	// 创建处理器
	handler := NewHandler(weatherClient)

	// 设置 Gin 模式
	mode := os.Getenv("GIN_MODE")
	if mode == "" {
		mode = gin.ReleaseMode
	}
	gin.SetMode(mode)

	// 创建路由器
	router := gin.Default()

	// 配置 CORS 中间件
	router.Use(corsMiddleware())

	// 配置路由
	SetupRoutes(router, handler)

	// 获取端口
	port := os.Getenv("API_PORT")
	if port == "" {
		port = "8080"
	}

	return &Server{
		router: router,
		port:   port,
	}, nil
}

// Start 启动 API 服务器
func (s *Server) Start() error {
	addr := fmt.Sprintf(":%s", s.port)
	log.Printf("🚀 Weather API 服务启动在 http://localhost%s", addr)
	log.Printf("📝 API 文档:")
	log.Printf("   - 健康检查: http://localhost%s/api/health", addr)
	log.Printf("   - 查询天气: http://localhost%s/api/weather?city=北京", addr)
	log.Printf("   - 版本信息: http://localhost%s/api/version", addr)

	return s.router.Run(addr)
}

// corsMiddleware CORS 中间件
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}
