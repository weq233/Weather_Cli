import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  String _currentCity = '北京';

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCity => _currentCity;

  // 获取天气数据
  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _weatherData = await _weatherService.getWeather(city);
      _currentCity = city;
    } catch (e) {
      _error = e.toString();
      _weatherData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 刷新当前城市天气
  Future<void> refreshWeather() async {
    if (_currentCity.isNotEmpty) {
      await fetchWeather(_currentCity);
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
