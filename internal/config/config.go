// internal/config/config.go
package config

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// APIConfig API 配置
type APIConfig struct {
	Host    string `json:"host"`
	Key     string `json:"key"`
	Timeout int    `json:"timeout"`
}

// ServerConfig 服务器配置
type ServerConfig struct {
	Port int    `json:"port"`
	Mode string `json:"mode"`
}

// Config 完整应用配置结构
type Config struct {
	API    APIConfig    `json:"api"`
	Server ServerConfig `json:"server"`
}

// 默认配置
const (
	DefaultAPIHost    = "p54nmuk5rq.re.qweatherapi.com"
	DefaultAPIKey     = "f694dcb7ce394ffe93408aa83f92a54e"
	DefaultAPITimeout = 10
	
	DefaultServerPort = 8080
	DefaultServerMode = "release"
)

// Load 加载配置文件
func Load() (*Config, error) {
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
			return getDefaultConfig(), nil
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

	// 应用默认值（如果配置文件中某些字段为空）
	applyDefaults(&config)

	return &config, nil
}

// getDefaultConfig 获取默认配置
func getDefaultConfig() *Config {
	return &Config{
		API: APIConfig{
			Host:    DefaultAPIHost,
			Key:     DefaultAPIKey,
			Timeout: DefaultAPITimeout,
		},
		Server: ServerConfig{
			Port: DefaultServerPort,
			Mode: DefaultServerMode,
		},
	}
}

// applyDefaults 应用默认值
func applyDefaults(config *Config) {
	// API 配置默认值
	if config.API.Host == "" {
		config.API.Host = DefaultAPIHost
	}
	if config.API.Key == "" {
		config.API.Key = DefaultAPIKey
	}
	if config.API.Timeout == 0 {
		config.API.Timeout = DefaultAPITimeout
	}

	// 服务器配置默认值
	if config.Server.Port == 0 {
		config.Server.Port = DefaultServerPort
	}
	if config.Server.Mode == "" {
		config.Server.Mode = DefaultServerMode
	}
}

// GetAPIKey 获取 API Key（优先级：参数 > 环境变量 > 配置文件）
func (c *Config) GetAPIKey(cmdLineKey string) string {
	if cmdLineKey != "" {
		return cmdLineKey
	}
	if envKey := os.Getenv("WEATHER_API_KEY"); envKey != "" {
		return envKey
	}
	return c.API.Key
}

// GetAPIHost 获取 API Host（优先级：环境变量 > 配置文件）
func (c *Config) GetAPIHost() string {
	if envHost := os.Getenv("WEATHER_API_HOST"); envHost != "" {
		return envHost
	}
	return c.API.Host
}

// GetAPITimeout 获取 API 超时时间
func (c *Config) GetAPITimeout() int {
	if envTimeout := os.Getenv("WEATHER_API_TIMEOUT"); envTimeout != "" {
		if timeout := parseInt(envTimeout); timeout > 0 {
			return timeout
		}
	}
	return c.API.Timeout
}

// GetServerPort 获取服务器端口
func (c *Config) GetServerPort() int {
	if envPort := os.Getenv("SERVER_PORT"); envPort != "" {
		if port := parseInt(envPort); port > 0 {
			return port
		}
	}
	return c.Server.Port
}

// GetServerMode 获取服务器模式
func (c *Config) GetServerMode() string {
	if envMode := os.Getenv("GIN_MODE"); envMode != "" {
		return envMode
	}
	return c.Server.Mode
}

// parseInt 辅助函数：将字符串转换为整数
func parseInt(s string) int {
	var result int
	fmt.Sscanf(s, "%d", &result)
	return result
}
