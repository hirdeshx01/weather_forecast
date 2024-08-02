class Weather {
  final String description;
  final double temperature;
  final String date;
  final String city;
  final String icon;
  final double minTemp;
  final double maxTemp;

  Weather({
    required this.description,
    required this.temperature,
    required this.date,
    required this.city,
    required this.icon,
    required this.minTemp,
    required this.maxTemp,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['weather'][0]['description'],
      temperature: (json['main']['temp'] as num).toDouble(),
      date: json['dt_txt'] ?? '',
      city: json['name'] ?? '',
      icon: json['weather'][0]['icon'],
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
    );
  }
}
