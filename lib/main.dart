import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_forecast/screens/home_screen.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        textTheme: GoogleFonts.questrialTextTheme(
          TextTheme(
            displayMedium: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            headlineSmall: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
            titleLarge: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.questrialTextTheme(
          const TextTheme(
            displayMedium: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            headlineSmall: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white30,
            ),
            titleLarge: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
