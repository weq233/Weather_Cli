// api/handlers.go
package api

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"weather-cli/internal/weather"
)

// Handler API 处理器
type Handler struct {
	weatherClient *weather.Client
}

// NewHandler 创建新的 API 处理器
func NewHandler(weatherClient *weather.Client) *Handler {
	return &Handler{
		weatherClient: weatherClient,
	}
}

// GetWeather 获取天气信息
// @Summary 查询城市天气
// @Description 根据城市名称查询实时天气信息
// @Tags 天气
// @Param city query string true "城市名称" example(北京)
// @Success 200 {object} weather.APIResponse
// @Failure 400 {object} weather.APIResponse
// @Failure 500 {object} weather.APIResponse
// @Router /api/weather [get]
func (h *Handler) GetWeather(c *gin.Context) {
	city := c.Query("city")
	if city == "" {
		c.JSON(http.StatusBadRequest, weather.APIResponse{
			Success: false,
			Message: "请提供城市名称参数 (?city=北京)",
		})
		return
	}

	// 查询天气
	result, err := h.weatherClient.QueryWeather(city)
	if err != nil {
		c.JSON(http.StatusInternalServerError, weather.APIResponse{
			Success: false,
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, weather.APIResponse{
		Success: true,
		Data:    result,
	})
}

// HealthCheck 健康检查
// @Summary 健康检查
// @Description 检查 API 服务是否正常运行
// @Tags 系统
// @Success 200 {object} weather.APIResponse
// @Router /api/health [get]
func (h *Handler) HealthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, weather.APIResponse{
		Success: true,
		Message: "Service is running",
	})
}

// GetVersion 获取版本信息
// @Summary 获取版本信息
// @Description 返回当前 API 版本号
// @Tags 系统
// @Success 200 {object} weather.APIResponse
// @Router /api/version [get]
func (h *Handler) GetVersion(c *gin.Context) {
	c.JSON(http.StatusOK, weather.APIResponse{
		Success: true,
		Data: gin.H{
			"version": "1.0.0",
			"name":    "Weather API",
		},
	})
}
