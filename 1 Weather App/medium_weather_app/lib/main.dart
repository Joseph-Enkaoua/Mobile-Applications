import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medium_weather_app/top.dart';
import 'package:medium_weather_app/body.dart';
import 'package:medium_weather_app/bottom.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Colors.lightBlue,
          onPrimary: Colors.white.withValues(alpha: 0.7),
          secondary: Colors.orange,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.transparent,
          onSurface: Colors.white,
        ),
      ),
      home: const WeatherApp(),
    );
  }
}

class WeatherApp extends StatefulWidget {
  const WeatherApp({super.key});

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String _errorMessage = "";
  final Map<String, String> _currentWeather = {};
  final List<Map<String, double>> _dailyWeather = [];
  final List<Map<String, double>> _weeklyWeather = [];
  final Map<String, String> _location = {};

  void setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  Future<void> getCurrentWeather(String latitude, String longitude) async {
    String url =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&weather_code';

    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _currentWeather['temp'] =
              "${responseData['current_weather']['temperature']}°C";
          _currentWeather['weathercode'] =
              "${responseData['current_weather']['weathercode']}";
          _currentWeather['windspeed'] =
              "${responseData['current_weather']['windspeed']}km/h";
        });
      } else {
        debugPrint(
            "Error fetching current weather. Response statusCode ${response.statusCode}");
        setErrorMessage(
            "Error: the service connection is lost. Please check your internet connection or try again later");
      }
    } catch (e) {
      debugPrint("Error fetching current weather: $e");
      setErrorMessage(
          "Error: the service connection is lost. Please check your internet connection or try again later");
    }
  }

  Future<void> getDailyWeather(String latitude, String longitude) async {
    String url =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,weather_code,wind_speed_10m&timezone=auto&forecast_days=1';

    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _dailyWeather.clear();
          int i = 0;
          while (i < 24) {
            int code = responseData['hourly']['weather_code'][i];
            _dailyWeather.add(
              {
                'hour': double.parse(responseData['hourly']['time'][i]
                    .toString()
                    .substring(11, 13)),
                'temp': responseData['hourly']['temperature_2m'][i],
                'weathercode': code.toDouble(),
                'windspeed': responseData['hourly']['wind_speed_10m'][i]
              },
            );
            i++;
          }
        });
      } else {
        debugPrint(
            "Error fetching daily weather. Response statusCode ${response.statusCode}");
        setErrorMessage(
            "Error: the service connection is lost. Please check your internet connection or try again later");
      }
    } catch (e) {
      debugPrint("Error fetching daily weather: $e");
      setErrorMessage(
          "Error: the service connection is lost. Please check your internet connection or try again later");
    }
  }

  Future<void> getWeeklyWeather(String latitude, String longitude) async {
    String url =
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto';

    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _weeklyWeather.clear();
          int i = 0;
          while (i < 7) {
            int code = responseData['daily']['weather_code'][i];
            _weeklyWeather.add(
              {
                'month': double.parse(responseData['daily']['time'][i]
                    .toString()
                    .substring(5, 7)),
                'day': double.parse(responseData['daily']['time'][i]
                    .toString()
                    .substring(8, 10)),
                'weathercode': code.toDouble(),
                'minTemp': responseData['daily']['temperature_2m_min'][i],
                'maxTemp': responseData['daily']['temperature_2m_max'][i],
              },
            );
            i++;
          }
        });
      } else {
        debugPrint(
            "Error fetching weekly weather. Response statusCode ${response.statusCode}");
        setErrorMessage(
            "Error: the service connection is lost. Please check your internet connection or try again later");
      }
    } catch (e) {
      debugPrint("Error fetching weekly weather: $e");
      setErrorMessage(
          "Error: the service connection is lost. Please check your internet connection or try again later");
    }
  }

  void setLocation(String city, String region, String country) {
    setState(() {
      _location['city'] = city;
      _location['region'] = region;
      _location['country'] = country;
    });
  }

  Future<void> fetchWeatherData(String latitude, String longitude) async {
    await Future.wait([
      getCurrentWeather(latitude, longitude),
      getDailyWeather(latitude, longitude),
      getWeeklyWeather(latitude, longitude),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Stack(
        children: <Widget>[
          // Full-screen background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/beach.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // The main content scaffold with transparent background
          Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: TopBar(
              setLocation: setLocation,
              fetchWeatherData: fetchWeatherData,
              setErrorMessage: setErrorMessage,
            ),
            body: SafeArea(
              child: AppBody(
                location: _location,
                currentWeather: _currentWeather,
                dailyWeather: _dailyWeather,
                weeklyWeather: _weeklyWeather,
                errorMessage: _errorMessage,
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: BottomBar(),
            ),
          ),
        ],
      ),
    );
  }
}
