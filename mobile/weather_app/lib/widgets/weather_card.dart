import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherCard({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    final weather = weatherData.weather;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 城市信息卡片
        _buildCityCard(),
        
        const SizedBox(height: 16),
        
        // 主要天气信息
        _buildMainWeatherCard(weather),
        
        const SizedBox(height: 16),
        
        // 详细天气信息
        _buildDetailGrid(weather),
        
        const SizedBox(height: 16),
        
        // 更新时间
        _buildUpdateTime(),
      ],
    );
  }

  // 城市信息卡片
  Widget _buildCityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weatherData.city,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (weatherData.province.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${weatherData.province}, ${weatherData.country}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 主要天气信息卡片
  Widget _buildMainWeatherCard(WeatherInfo weather) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 天气图标和温度
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getWeatherIcon(weather.text, size: 80),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temp}°C',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    weather.text,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 体感温度
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thermostat, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  '体感温度 ${weather.feelsLike}°C',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 详细信息网格
  Widget _buildDetailGrid(WeatherInfo weather) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildDetailItem(
          icon: FontAwesomeIcons.wind,
          label: '风向',
          value: weather.windDir,
          color: Colors.teal,
        ),
        _buildDetailItem(
          icon: FontAwesomeIcons.wind,
          label: '风力',
          value: '${weather.windScale}级',
          color: Colors.teal,
        ),
        _buildDetailItem(
          icon: Icons.water_drop,
          label: '湿度',
          value: '${weather.humidity}%',
          color: Colors.blue,
        ),
        _buildDetailItem(
          icon: Icons.visibility,
          label: '能见度',
          value: '${weather.vis}km',
          color: Colors.purple,
        ),
        _buildDetailItem(
          icon: Icons.grain,
          label: '降水量',
          value: '${weather.precip}mm',
          color: Colors.indigo,
        ),
        _buildDetailItem(
          icon: Icons.compress,
          label: '气压',
          value: '${weather.pressure}hPa',
          color: Colors.brown,
        ),
      ],
    );
  }

  // 详细信息项
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 更新时间
  Widget _buildUpdateTime() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '数据更新: ${_formatTime(weatherData.updateTime)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // 根据天气文本获取图标
  Widget _getWeatherIcon(String weatherText, {double size = 48}) {
    String iconData = '☀️';
    
    if (weatherText.contains('晴')) {
      iconData = '☀️';
    } else if (weatherText.contains('云')) {
      iconData = '☁️';
    } else if (weatherText.contains('阴')) {
      iconData = '☁️';
    } else if (weatherText.contains('雨')) {
      iconData = '🌧️';
    } else if (weatherText.contains('雪')) {
      iconData = '❄️';
    } else if (weatherText.contains('雷')) {
      iconData = '⛈️';
    } else if (weatherText.contains('雾') || weatherText.contains('霾')) {
      iconData = '🌫️';
    }
    
    return Text(
      iconData,
      style: TextStyle(fontSize: size),
    );
  }

  // 格式化时间
  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '未知';
    try {
      // 简单的时间格式化处理
      return timeStr.replaceAll('T', ' ').substring(0, 19);
    } catch (e) {
      return timeStr;
    }
  }
}
