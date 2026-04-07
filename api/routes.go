// api/routes.go
package api

import (
	"github.com/gin-gonic/gin"
)

// SetupRoutes 配置 API 路由
func SetupRoutes(r *gin.Engine, handler *Handler) {
	// API v1 路由组
	api := r.Group("/api")
	{
		// 系统接口
		api.GET("/health", handler.HealthCheck)
		api.GET("/version", handler.GetVersion)

		// 天气查询接口
		api.GET("/weather", handler.GetWeather)
	}

	// 根路径欢迎信息
	r.GET("/", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Welcome to Weather API",
			"docs":    "访问 /api/health 检查服务状态",
			"example": "/api/weather?city=北京",
		})
	})
}
