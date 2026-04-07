// internal/weather/client.go
package weather

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"weather-cli/internal/config"
)

// Client 天气查询客户端
type Client struct {
	config *config.Config
}

// NewClient 创建新的天气客户端
func NewClient(cfg *config.Config) *Client {
	return &Client{
		config: cfg,
	}
}

// SearchCity 搜索城市获取 Location ID
func (c *Client) SearchCity(cityName string) (*CityLocation, error) {
	apiHost := c.config.GetAPIHost()
	apiKey := c.config.GetAPIKey("")

	// 构建 GeoAPI URL
	searchURL := fmt.Sprintf("https://%s/geo/v2/city/lookup?location=%s", apiHost, cityName)

	timeout := time.Duration(c.config.GetAPITimeout()) * time.Second
	client := &http.Client{
		Timeout: timeout,
	}

	// 创建请求并添加 API Key 到 Header
	req, err := http.NewRequest("GET", searchURL, nil)
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	req.Header.Set("X-QW-Api-Key", apiKey)

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("HTTP 请求失败: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %w", err)
	}

	var cityResp CitySearchResponse
	if err := json.Unmarshal(body, &cityResp); err != nil {
		return nil, fmt.Errorf("解析 JSON 失败: %w", err)
	}

	if cityResp.Code != "200" {
		return nil, fmt.Errorf("城市搜索 API 返回错误，code: %s", cityResp.Code)
	}

	if len(cityResp.Location) == 0 {
		return nil, fmt.Errorf("未找到城市: %s", cityName)
	}

	// 返回第一个匹配的城市信息
	return &cityResp.Location[0], nil
}

// GetWeather 查询实时天气
func (c *Client) GetWeather(locationID string) (*QWeatherResponse, error) {
	apiHost := c.config.GetAPIHost()
	apiKey := c.config.GetAPIKey("")

	weatherURL := fmt.Sprintf("https://%s/v7/weather/now?location=%s", apiHost, locationID)

	timeout := time.Duration(c.config.GetAPITimeout()) * time.Second
	client := &http.Client{
		Timeout: timeout,
	}

	// 创建请求并添加 API Key 到 Header
	req, err := http.NewRequest("GET", weatherURL, nil)
	if err != nil {
		return nil, fmt.Errorf("创建请求失败: %w", err)
	}
	req.Header.Set("X-QW-Api-Key", apiKey)

	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("HTTP 请求失败: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("读取响应失败: %w", err)
	}

	var weatherResp QWeatherResponse
	if err := json.Unmarshal(body, &weatherResp); err != nil {
		return nil, fmt.Errorf("解析 JSON 失败: %w", err)
	}

	// 检查 API 返回码
	if weatherResp.Code != "200" {
		return nil, fmt.Errorf("API 返回错误，code: %s", weatherResp.Code)
	}

	return &weatherResp, nil
}

// QueryWeather 完整的天气查询流程（搜索城市 + 获取天气）
func (c *Client) QueryWeather(cityName string) (*WeatherResult, error) {
	// 步骤 1: 搜索城市获取 Location ID
	cityInfo, err := c.SearchCity(cityName)
	if err != nil {
		return nil, fmt.Errorf("搜索城市失败: %w", err)
	}

	// 步骤 2: 使用 Location ID 查询实时天气
	weatherResp, err := c.GetWeather(cityInfo.ID)
	if err != nil {
		return nil, fmt.Errorf("查询天气失败: %w", err)
	}

	// 组装结果
	result := &WeatherResult{
		City:       cityInfo.Name,
		Province:   cityInfo.Province,
		Country:    cityInfo.Country,
		LocationID: cityInfo.ID,
		Weather:    weatherResp.Now,
		UpdateTime: weatherResp.UpdateTime,
	}

	return result, nil
}
