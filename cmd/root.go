package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/spf13/cobra"
)

var (
	version = "1.0.0"
	apiKey  string
	city    string

	// 默认 API 配置(可通过配置文件、环境变量或命令行参数覆盖)
	defaultAPIHost = "p54nmuk5rq.re.qweatherapi.com"
	defaultAPIKey  = "f694dcb7ce394ffe93408aa83f92a54e"
)

// 配置结构
type Config struct {
	APIHost string `json:"api_host"`
	APIKey  string `json:"api_key"`
	Timeout int    `json:"timeout"`
}

// 加载配置文件
func loadConfig() (*Config, error) {
	// 优先从当前工作目录查找 config.json
	configPath := "config.json"

	// 检查配置文件是否存在
	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		// 如果不存在,尝试从可执行文件所在目录查找
		execPath, err := os.Executable()
		if err == nil {
			execDir := filepath.Dir(execPath)
			configPath = filepath.Join(execDir, "config.json")
		}

		// 再次检查
		if _, err := os.Stat(configPath); os.IsNotExist(err) {
			// 如果仍不存在,使用默认配置
			return &Config{
				APIHost: defaultAPIHost,
				APIKey:  defaultAPIKey,
				Timeout: 10,
			}, nil
		}
	}

	// 读取配置文件
	data, err := os.ReadFile(configPath)
	if err != nil {
		return nil, fmt.Errorf("读取配置文件失败: %w", err)
	}

	var config Config
	if err := json.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("解析配置文件失败: %w", err)
	}

	// 如果配置文件中某些字段为空,使用默认值
	if config.APIHost == "" {
		config.APIHost = defaultAPIHost
	}
	if config.APIKey == "" {
		config.APIKey = defaultAPIKey
	}
	if config.Timeout == 0 {
		config.Timeout = 10
	}

	return &config, nil
}

// 和风天气 API 响应结构
type QWeatherResponse struct {
	Code       string      `json:"code"`
	UpdateTime string      `json:"updateTime"`
	FxLink     string      `json:"fxLink"`
	Now        WeatherData `json:"now"`
}

type WeatherData struct {
	ObsTime   string `json:"obsTime"`
	Temp      string `json:"temp"`
	FeelsLike string `json:"feelsLike"`
	Icon      string `json:"icon"`
	Text      string `json:"text"`
	Wind360   string `json:"wind360"`
	WindDir   string `json:"windDir"`
	WindScale string `json:"windScale"`
	WindSpeed string `json:"windSpeed"`
	Humidity  string `json:"humidity"`
	Precip    string `json:"precip"`
	Pressure  string `json:"pressure"`
	Vis       string `json:"vis"`
	Cloud     string `json:"cloud"`
	Dew       string `json:"dew"`
}

// 城市搜索结果
type CitySearchResponse struct {
	Code     string         `json:"code"`
	Location []CityLocation `json:"location"`
}

type CityLocation struct {
	Name     string `json:"name"`
	ID       string `json:"id"`
	Country  string `json:"country"`
	Province string `json:"adm1"`
}

var rootCmd = &cobra.Command{
	Use:   "weather-cli",
	Short: "天气查询 CLI 工具",
	Long: `一个基于 Go 的天气查询命令行工具，支持和风天气 API。
可以通过环境变量、配置文件或命令行参数配置 API 密钥和城市信息。`,
	RunE: func(cmd *cobra.Command, args []string) error {
		// 加载配置文件(获取默认值)
		config, err := loadConfig()
		if err != nil {
			return fmt.Errorf("加载配置失败: %w", err)
		}

		// 优先使用命令行参数，否则使用环境变量，最后使用配置文件默认值
		if apiKey == "" {
			apiKey = os.Getenv("WEATHER_API_KEY")
			if apiKey == "" {
				apiKey = config.APIKey
			}
		}

		if city == "" {
			city = os.Getenv("WEATHER_CITY")
		}

		if city == "" {
			return fmt.Errorf("请指定城市名称 (--city 或 WEATHER_CITY 环境变量)")
		}

		fmt.Printf("正在查询 %s 的天气...\n\n", city)

		// 查询天气
		err = queryWeather(apiKey, city)
		if err != nil {
			return fmt.Errorf("查询失败: %w", err)
		}

		return nil
	},
	Version: version,
}

func init() {
	// 添加全局标志
	rootCmd.PersistentFlags().StringVarP(&apiKey, "api-key", "k", "", "和风天气 API 密钥")
	rootCmd.PersistentFlags().StringVarP(&city, "city", "c", "", "要查询的城市名称")

	// 添加子命令
	rootCmd.AddCommand(versionCmd)
	rootCmd.AddCommand(configCmd)
}

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "显示版本号",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Printf("weather-cli version %s\n", version)
	},
}

var configCmd = &cobra.Command{
	Use:   "config",
	Short: "显示配置信息",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("当前配置:")
		fmt.Printf("  API Key: %s\n", maskString(apiKey))
		fmt.Printf("  City: %s\n", city)
		fmt.Printf("  Timezone: %s\n", os.Getenv("TZ"))
	},
}

// 搜索城市获取 Location ID
func searchCity(apiKey, cityName string) (string, error) {
	// 加载配置(优先级: 命令行参数 > 环境变量 > 配置文件 > 默认值)
	config, err := loadConfig()
	if err != nil {
		return "", fmt.Errorf("加载配置失败: %w", err)
	}

	// 获取 API Host
	apiHost := os.Getenv("WEATHER_API_HOST")
	if apiHost == "" {
		apiHost = config.APIHost
	}

	// 获取 API Key
	if apiKey == "" {
		apiKey = os.Getenv("WEATHER_API_KEY")
		if apiKey == "" {
			apiKey = config.APIKey
		}
	}

	// 构建 GeoAPI URL
	searchURL := fmt.Sprintf("https://%s/geo/v2/city/lookup?location=%s", apiHost, cityName)

	timeout := time.Duration(config.Timeout) * time.Second
	client := &http.Client{
		Timeout: timeout,
	}

	// 创建请求并添加 API Key 到 Header
	req, err := http.NewRequest("GET", searchURL, nil)
	if err != nil {
		return "", fmt.Errorf("创建请求失败: %w", err)
	}
	req.Header.Set("X-QW-Api-Key", apiKey)

	resp, err := client.Do(req)
	if err != nil {
		return "", fmt.Errorf("HTTP 请求失败: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("读取响应失败: %w", err)
	}

	var cityResp CitySearchResponse
	if err := json.Unmarshal(body, &cityResp); err != nil {
		return "", fmt.Errorf("解析 JSON 失败: %w，请检查 API Key 是否正确", err)
	}

	if cityResp.Code != "200" {
		return "", fmt.Errorf("城市搜索 API 返回错误，code: %s", cityResp.Code)
	}

	if len(cityResp.Location) == 0 {
		return "", fmt.Errorf("未找到城市: %s", cityName)
	}

	// 返回第一个匹配的城市 ID
	return cityResp.Location[0].ID, nil
}

// 查询天气
func queryWeather(apiKey, cityName string) error {
	// 检查是否为演示模式
	if apiKey == "demo" {
		fmt.Println("⚠️  演示模式：使用模拟数据")
		printDemoWeather(cityName)
		return nil
	}

	// 加载配置
	config, err := loadConfig()
	if err != nil {
		return fmt.Errorf("加载配置失败: %w", err)
	}

	// 步骤 1: 搜索城市获取 Location ID
	locationID, err := searchCity(apiKey, cityName)
	if err != nil {
		return fmt.Errorf("搜索城市失败: %w", err)
	}

	// 步骤 2: 使用 Location ID 查询实时天气
	apiHost := os.Getenv("WEATHER_API_HOST")
	if apiHost == "" {
		apiHost = config.APIHost
	}

	if apiKey == "" {
		apiKey = os.Getenv("WEATHER_API_KEY")
		if apiKey == "" {
			apiKey = config.APIKey
		}
	}

	weatherURL := fmt.Sprintf("https://%s/v7/weather/now?location=%s", apiHost, locationID)

	timeout := time.Duration(config.Timeout) * time.Second
	client := &http.Client{
		Timeout: timeout,
	}

	// 创建请求并添加 API Key 到 Header
	req, err := http.NewRequest("GET", weatherURL, nil)
	if err != nil {
		return fmt.Errorf("创建请求失败: %w", err)
	}
	req.Header.Set("X-QW-Api-Key", apiKey)

	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("HTTP 请求失败: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("读取响应失败: %w", err)
	}

	var weatherResp QWeatherResponse
	if err := json.Unmarshal(body, &weatherResp); err != nil {
		return fmt.Errorf("解析 JSON 失败: %w", err)
	}

	// 检查 API 返回码
	if weatherResp.Code != "200" {
		return fmt.Errorf("API 返回错误，code: %s，请检查 API Key 是否正确 (提示: 使用 --api-key \"demo\" 查看演示数据)", weatherResp.Code)
	}

	// 格式化输出天气信息
	printWeatherInfo(cityName, weatherResp)

	return nil
}

// 打印演示天气数据
func printDemoWeather(cityName string) {
	demoResp := QWeatherResponse{
		Code:       "200",
		UpdateTime: time.Now().Format("2006-01-02T15:04-07:00"),
		Now: WeatherData{
			ObsTime:   time.Now().Format("2006-01-02T15:04"),
			Temp:      "22",
			FeelsLike: "23",
			Text:      "晴",
			WindDir:   "东南风",
			WindScale: "2",
			Humidity:  "55",
			Vis:       "10",
			Precip:    "0",
			Pressure:  "1013",
		},
	}
	printWeatherInfo(cityName, demoResp)
	fmt.Println("\n💡 提示: 这是演示数据。要使用真实数据，请:")
	fmt.Println("   1. 访问 https://console.qweather.com/ 获取您的 API Key")
	fmt.Println("   2. 使用命令: weather-cli --api-key \"您的Key\" --city \"北京\"")
}

// 格式化输出天气信息
func printWeatherInfo(cityName string, weatherResp QWeatherResponse) {
	now := weatherResp.Now

	fmt.Println("╔══════════════════════════════════════════╗")
	fmt.Printf("║  🌤️  %s 天气实况\n", centerText(cityName, 34))
	fmt.Println("╠══════════════════════════════════════════╣")
	fmt.Printf("║  🌡️  温度: %-3s°C", now.Temp)
	fmt.Printf("%*s║\n", 28-len(now.Temp), "")
	fmt.Printf("║  🌡️  体感温度: %-3s°C", now.FeelsLike)
	fmt.Printf("%*s║\n", 25-len(now.FeelsLike), "")
	fmt.Printf("║  ☁️  天气: %-6s", now.Text)
	fmt.Printf("%*s║\n", 26-len(now.Text), "")
	fmt.Printf("║  💨  风向: %-6s", now.WindDir)
	fmt.Printf("%*s║\n", 26-len(now.WindDir), "")
	fmt.Printf("║  💨  风力: %-3s级", now.WindScale)
	fmt.Printf("%*s║\n", 28-len(now.WindScale), "")
	fmt.Printf("║  💧  湿度: %-3s%%", now.Humidity)
	fmt.Printf("%*s║\n", 28-len(now.Humidity), "")
	fmt.Printf("║  👁️  能见度: %-3skm", now.Vis)
	fmt.Printf("%*s║\n", 27-len(now.Vis), "")
	fmt.Printf("║  🌧️  降水量: %-3smm", now.Precip)
	fmt.Printf("%*s║\n", 27-len(now.Precip), "")
	fmt.Printf("║  🔽  气压: %-4shPa", now.Pressure)
	fmt.Printf("%*s║\n", 26-len(now.Pressure), "")
	fmt.Println("╚══════════════════════════════════════════╝")
	fmt.Printf("📅 数据更新时间: %s\n", formatTime(weatherResp.UpdateTime))
}

// 辅助函数：居中文本
func centerText(text string, width int) string {
	textLen := len([]rune(text))
	if textLen >= width {
		return text
	}
	padding := (width - textLen) / 2
	result := ""
	for i := 0; i < padding; i++ {
		result += " "
	}
	result += text
	for i := 0; i < width-padding-textLen; i++ {
		result += " "
	}
	return result
}

// 辅助函数：格式化时间
func formatTime(timeStr string) string {
	t, err := time.Parse("2006-01-02T15:04-07:00", timeStr)
	if err != nil {
		return timeStr
	}
	return t.Format("2006-01-02 15:04:05")
}

// 辅助函数：掩码敏感信息
func maskString(s string) string {
	if s == "" {
		return "(未设置)"
	}
	if len(s) <= 8 {
		return "****"
	}
	return "****" + s[len(s)-4:]
}
