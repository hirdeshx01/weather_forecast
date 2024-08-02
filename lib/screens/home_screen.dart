import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_forecast/services/weather_service.dart';
import 'package:weather_forecast/models/weather.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  Weather? _currentWeather;
  List<Weather>? _forecast;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLastCity();
  }

  String _getDayOfWeek(String date) {
    final DateTime dateTime = DateTime.parse(date);
    final DateFormat formatter = DateFormat('EEEE');
    final String dayOfWeek = formatter.format(dateTime);
    return dayOfWeek.substring(0, 3);
  }

  Future<void> _loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString('lastCity');
    if (lastCity != null) {
      _fetchWeather(lastCity);
    }
  }

  Future<void> _fetchWeather(String city) async {
    setState(() {
      _isLoading = true;
    });
    final weatherService = WeatherService();

    try {
      final currentWeather = await weatherService.fetchCurrentWeather(city);
      final forecast = await weatherService.fetchWeatherForecast(city);
      setState(() {
        _currentWeather = currentWeather;
        _forecast = forecast;
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('lastCity', city);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We are unable to retrieve the data at the moment.',
              textAlign: TextAlign.center,
            ),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: const Text('Weather Forecast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 50),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                labelText: 'Enter city',
                suffixIcon: IconButton(
                  onPressed: () {
                    _fetchWeather(_cityController.text);
                  },
                  icon: const Icon(Icons.search_rounded),
                ),
                prefixIcon: const Icon(Icons.location_on_rounded),
              ),
              onSubmitted: _fetchWeather,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : _currentWeather != null
                    ? Column(
                        children: [
                          Text(
                            _currentWeather!.city,
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black38,
                            ),
                          ),
                          Text(
                            '${_currentWeather!.temperature}°C',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _currentWeather!.temperature <= 0
                                  ? Colors.blue
                                  : _currentWeather!.temperature > 0 &&
                                          _currentWeather!.temperature <= 15
                                      ? Colors.indigo
                                      : _currentWeather!.temperature > 15 &&
                                              _currentWeather!.temperature < 30
                                          ? Colors.deepPurple
                                          : Colors.pink,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 120),
                            child: Divider(),
                          ),
                          Text(
                            _currentWeather!.description[0].toUpperCase() +
                                _currentWeather!.description.substring(1),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text(
                          'Data not found!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                          ),
                        ),
                      ),
            const SizedBox(height: 20),
            _isLoading
                ? const SizedBox()
                : _forecast != null
                    ? Expanded(
                        child: Card(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text(
                                '5-Day Forecast:',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _forecast!.length,
                                  itemBuilder: (context, index) {
                                    final weather = _forecast![index];
                                    final iconUrl =
                                        'http://openweathermap.org/img/wn/${weather.icon}@2x.png';

                                    return Column(
                                      children: [
                                        ListTile(
                                          title: Row(
                                            children: [
                                              Text(
                                                '${_getDayOfWeek(weather.date)}:  ',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                weather.description,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black45,
                                                ),
                                              )
                                            ],
                                          ),
                                          subtitle: Text(
                                            '${weather.temperature}°C',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: weather.temperature <= 0
                                                  ? Colors.blue
                                                  : weather.temperature > 0 &&
                                                          weather.temperature <=
                                                              15
                                                      ? Colors.indigo
                                                      : weather.temperature >
                                                                  15 &&
                                                              weather.temperature <
                                                                  30
                                                          ? Colors.deepPurple
                                                          : Colors.pink,
                                            ),
                                          ),
                                          leading: Image.network(
                                            iconUrl,
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox()
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}
