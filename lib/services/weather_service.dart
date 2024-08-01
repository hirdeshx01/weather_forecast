import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_forecast/models/weather.dart';

class WeatherService {
  final String apiKey = 'b1e69b4a4bee3e76345781cdd8834e4e';

  Future<Weather> fetchCurrentWeather(String city) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<Weather>> fetchWeatherForecast(String city) async {
    final response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['list'];
      return list.map((json) => Weather.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load weather forecast');
    }
  }
}
