// internal/weather/models.go
package weather

// QWeatherResponse 和风天气 API 响应结构
type QWeatherResponse struct {
	Code       string      `json:"code"`
	UpdateTime string      `json:"updateTime"`
	FxLink     string      `json:"fxLink"`
	Now        WeatherData `json:"now"`
}

// WeatherData 天气数据结构
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

// CitySearchResponse 城市搜索结果
type CitySearchResponse struct {
	Code     string         `json:"code"`
	Location []CityLocation `json:"location"`
}

// CityLocation 城市位置信息
type CityLocation struct {
	Name     string `json:"name"`
	ID       string `json:"id"`
	Country  string `json:"country"`
	Province string `json:"adm1"`
}

// WeatherResult 统一的天气查询结果（用于 API 返回）
type WeatherResult struct {
	City      string      `json:"city"`
	Province  string      `json:"province,omitempty"`
	Country   string      `json:"country,omitempty"`
	LocationID string     `json:"location_id"`
	Weather   WeatherData `json:"weather"`
	UpdateTime string     `json:"update_time"`
}

// APIResponse 统一的 API 响应格式
type APIResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}
