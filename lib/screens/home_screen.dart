import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_forecast/services/weather_service.dart';
import 'package:weather_forecast/models/weather.dart';

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
                'Unable to fetch data. Please make sure you have an active internet connection and entered a valid city.'),
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
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
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
                            color: Colors.black45,
                          ),
                        ),
                      ),
            if (_forecast != null) ...[
              const SizedBox(height: 20),
              const Text('5-Day Forecast:'),
              Expanded(
                child: ListView.builder(
                  itemCount: _forecast!.length,
                  itemBuilder: (context, index) {
                    final weather = _forecast![index];
                    return ListTile(
                      title: Text('${weather.date}: ${weather.description}'),
                      subtitle: Text('Temp: ${weather.temperature}°C'),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
