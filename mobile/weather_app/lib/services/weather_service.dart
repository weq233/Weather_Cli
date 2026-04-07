import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  // API 基础 URL - 根据实际情况修改
  // 本地开发：Android 模拟器使用 10.0.2.2，iOS 模拟器使用 localhost
  // 生产环境：使用服务器公网 IP 或域名
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  
  // 获取天气数据
  Future<WeatherData> getWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather?city=$city'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          return WeatherData.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? '获取天气失败');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('网络连接失败，请检查网络设置');
      } else if (e.toString().contains('Timeout')) {
        throw Exception('请求超时，请稍后重试');
      }
      rethrow;
    }
  }

  // 健康检查
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
