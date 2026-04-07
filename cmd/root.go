package main

import (
	"fmt"
	"os"
	"time"

	"github.com/spf13/cobra"
	"weather-cli/internal/config"
	"weather-cli/internal/weather"
)

var (
	version = "1.0.0"
	apiKey  string
	city    string
)

var rootCmd = &cobra.Command{
	Use:   "weather-cli",
	Short: "天气查询 CLI 工具",
	Long: `一个基于 Go 的天气查询命令行工具，支持和风天气 API。
可以通过环境变量、配置文件或命令行参数配置 API 密钥和城市信息。`,
	RunE: func(cmd *cobra.Command, args []string) error {
		// 加载配置
		cfg, err := config.Load()
		if err != nil {
			return fmt.Errorf("加载配置失败: %w", err)
		}

		// 获取 API Key（优先级：命令行 > 环境变量 > 配置文件）
		effectiveAPIKey := cfg.GetAPIKey(apiKey)
		if effectiveAPIKey == "" {
			return fmt.Errorf("请提供 API Key (--api-key 或 WEATHER_API_KEY 环境变量)")
		}

		// 获取城市名称
		effectiveCity := city
		if effectiveCity == "" {
			effectiveCity = os.Getenv("WEATHER_CITY")
		}

		if effectiveCity == "" {
			return fmt.Errorf("请指定城市名称 (--city 或 WEATHER_CITY 环境变量)")
		}

		fmt.Printf("正在查询 %s 的天气...\n\n", effectiveCity)

		// 检查是否为演示模式
		if effectiveAPIKey == "demo" {
			fmt.Println("⚠️  演示模式：使用模拟数据")
			printDemoWeather(effectiveCity)
			return nil
		}

		// 创建天气客户端
		client := weather.NewClient(cfg)

		// 查询天气
		result, err := client.QueryWeather(effectiveCity)
		if err != nil {
			return fmt.Errorf("查询失败: %w", err)
		}

		// 格式化输出
		printWeatherResult(result)

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
		cfg, _ := config.Load()
		fmt.Println("当前配置:")
		fmt.Printf("  API Host: %s\n", cfg.GetAPIHost())
		fmt.Printf("  API Key: %s\n", maskString(cfg.GetAPIKey(apiKey)))
		fmt.Printf("  City: %s\n", city)
		fmt.Printf("  Timeout: %ds\n", cfg.GetAPITimeout())
		fmt.Printf("  Server Port: %d\n", cfg.GetServerPort())
		fmt.Printf("  Server Mode: %s\n", cfg.GetServerMode())
		fmt.Printf("  Timezone: %s\n", os.Getenv("TZ"))
	},
}

// 打印演示天气数据
func printDemoWeather(cityName string) {
	demoResp := weather.QWeatherResponse{
		Code:       "200",
		UpdateTime: time.Now().Format("2006-01-02T15:04-07:00"),
		Now: weather.WeatherData{
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

	result := &weather.WeatherResult{
		City:       cityName,
		Weather:    demoResp.Now,
		UpdateTime: demoResp.UpdateTime,
	}
	printWeatherResult(result)

	fmt.Println("\n💡 提示: 这是演示数据。要使用真实数据，请:")
	fmt.Println("   1. 访问 https://console.qweather.com/ 获取您的 API Key")
	fmt.Println("   2. 使用命令: weather-cli --api-key \"您的Key\" --city \"北京\"")
}

// 格式化输出天气信息
func printWeatherResult(result *weather.WeatherResult) {
	now := result.Weather

	fmt.Println("╔══════════════════════════════════════════╗")
	fmt.Printf("║  🌤️  %s 天气实况\n", centerText(result.City, 34))
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
	fmt.Printf("📅 数据更新时间: %s\n", formatTime(result.UpdateTime))
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
