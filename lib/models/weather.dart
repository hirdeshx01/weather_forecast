class Weather {
  final String description;
  final double temperature;
  final String date;
  final String city;
  final String icon;

  Weather(
      {required this.description,
      required this.temperature,
      required this.date,
      required this.city,
      required this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['weather'][0]['description'],
      temperature: (json['main']['temp'] as num).toDouble(),
      date: json['dt_txt'] ?? '',
      city: json['name'] ?? '',
      icon: json['weather'][0]['icon'],
    );
  }
}
