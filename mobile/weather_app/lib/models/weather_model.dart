class WeatherData {
  final String city;
  final String province;
  final String country;
  final String locationId;
  final WeatherInfo weather;
  final String updateTime;

  WeatherData({
    required this.city,
    required this.province,
    required this.country,
    required this.locationId,
    required this.weather,
    required this.updateTime,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      country: json['country'] ?? '',
      locationId: json['location_id'] ?? '',
      weather: WeatherInfo.fromJson(json['weather']),
      updateTime: json['update_time'] ?? '',
    );
  }
}

class WeatherInfo {
  final String obsTime;
  final String temp;
  final String feelsLike;
  final String icon;
  final String text;
  final String wind360;
  final String windDir;
  final String windScale;
  final String windSpeed;
  final String humidity;
  final String precip;
  final String pressure;
  final String vis;
  final String cloud;
  final String dew;

  WeatherInfo({
    required this.obsTime,
    required this.temp,
    required this.feelsLike,
    required this.icon,
    required this.text,
    required this.wind360,
    required this.windDir,
    required this.windScale,
    required this.windSpeed,
    required this.humidity,
    required this.precip,
    required this.pressure,
    required this.vis,
    required this.cloud,
    required this.dew,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      obsTime: json['obsTime'] ?? '',
      temp: json['temp'] ?? '0',
      feelsLike: json['feelsLike'] ?? '0',
      icon: json['icon'] ?? '',
      text: json['text'] ?? '',
      wind360: json['wind360'] ?? '',
      windDir: json['windDir'] ?? '',
      windScale: json['windScale'] ?? '',
      windSpeed: json['windSpeed'] ?? '',
      humidity: json['humidity'] ?? '',
      precip: json['precip'] ?? '',
      pressure: json['pressure'] ?? '',
      vis: json['vis'] ?? '',
      cloud: json['cloud'] ?? '',
      dew: json['dew'] ?? '',
    );
  }
}
