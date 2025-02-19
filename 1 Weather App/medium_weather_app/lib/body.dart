import 'package:flutter/material.dart';
import 'package:medium_weather_app/current.dart';
import 'package:medium_weather_app/daily.dart';
import 'package:medium_weather_app/weekly.dart';

class AppBody extends StatelessWidget {
  const AppBody(
      {super.key,
      required this.location,
      required this.currentWeather,
      required this.dailyWeather,
      required this.weeklyWeather,
      required this.errorMessage});

  final String errorMessage;
  final Map<String, String> location;
  final Map<String, String> currentWeather;
  final List<Map<String, double>> dailyWeather;
  final List<Map<String, double>> weeklyWeather;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        CurrentView(
            location: location,
            currentWeather: currentWeather,
            errorMessage: errorMessage),
        DailyView(
          location: location,
          dailyWeather: dailyWeather,
          errorMessage: errorMessage,
        ),
        WeeklyyView(
          location: location,
          weeklyWeather: weeklyWeather,
          errorMessage: errorMessage,
        ),
      ],
    );
  }
}
