import 'package:flutter/material.dart';

class BodyTitle extends StatelessWidget {
  const BodyTitle({super.key, required this.location});

  final Map<String, String> location;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        if (width == double.infinity || height == double.infinity) {
          width = MediaQuery.of(context).size.width * 0.85;
          height = MediaQuery.of(context).size.height * 0.29;
        }

        return Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 30),
          child: Column(
            children: [
              Text(
                "${location['city']}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: width * 0.02 + 16,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 2,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              Text(
                location['city'] == location['region']
                    ? "${location['country']}"
                    : "${location['region']}, ${location['country']}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: width * 0.02 + 14,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 0),
                      blurRadius: 2,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          Card.filled(
            color: Theme.of(context).colorScheme.onPrimary,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Icon(
                    Icons.tsunami,
                    size: 42,
                    color: Colors.white,
                  ),
                  SizedBox(height: 14),
                  Text(
                    message,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        children: [
          Card.filled(
            color: Theme.of(context).colorScheme.onPrimary,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.amber,
                    size: 42,
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherDescriptionMaps extends StatelessWidget {
  WeatherDescriptionMaps(
      {super.key,
      required this.weatherCode,
      required this.size,
      required this.color});

  final String weatherCode;
  final double size;
  final Color color;

  // Weather code to description mapping
  static final Map<String, String> weatherMap = {
    '0': 'Clear sky',
    '1': 'Mainly clear',
    '2': 'Partly cloudy',
    '3': 'Overcast',
    '45': 'Fog and depositing rime fog',
    '48': 'Fog and depositing rime fog',
    '51': 'Drizzle: Light intensity',
    '53': 'Drizzle: Moderate intensity',
    '55': 'Drizzle: Dense intensity',
    '56': 'Freezing Drizzle: Light intensity',
    '57': 'Freezing Drizzle: Dense intensity',
    '61': 'Rain: Slight intensity',
    '63': 'Rain: Moderate intensity',
    '65': 'Rain: Heavy intensity',
    '66': 'Freezing Rain: Light intensity',
    '67': 'Freezing Rain: Heavy intensity',
    '71': 'Snow fall: Slight intensity',
    '73': 'Snow fall: Moderate intensity',
    '75': 'Snow fall: Heavy intensity',
    '77': 'Snow grains',
    '80': 'Rain showers: Slight intensity',
    '81': 'Rain showers: Moderate intensity',
    '82': 'Rain showers: Violent intensity',
    '85': 'Snow showers: Slight intensity',
    '86': 'Snow showers: Heavy intensity',
    '95': 'Thunderstorm: Slight or moderate',
    '96': 'Thunderstorm with slight hail',
    '99': 'Thunderstorm with heavy hail',
  };

  // Mapping weather codes to Material icons
  final Map<String, IconData> weatherIconMapping = {
    '0': Icons.wb_sunny,
    '1': Icons.wb_sunny,
    '2': Icons.wb_cloudy,
    '3': Icons.cloud,
    '45': Icons.filter_drama,
    '48': Icons.filter_drama,
    '51': Icons.grain,
    '53': Icons.grain,
    '55': Icons.grain,
    '56': Icons.ac_unit,
    '57': Icons.ac_unit,
    '61': Icons.beach_access,
    '63': Icons.beach_access,
    '65': Icons.beach_access,
    '66': Icons.ac_unit,
    '67': Icons.ac_unit,
    '71': Icons.ac_unit,
    '73': Icons.ac_unit,
    '75': Icons.ac_unit,
    '77': Icons.ac_unit,
    '80': Icons.grain,
    '81': Icons.grain,
    '82': Icons.grain,
    '85': Icons.ac_unit,
    '86': Icons.ac_unit,
    '95': Icons.flash_on,
    '96': Icons.flash_on,
    '99': Icons.flash_on,
  };

  static String getWeatherDescription(String code) {
    return weatherMap[code] ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      weatherIconMapping[weatherCode] ?? Icons.question_mark,
      size: size,
      color: color,
    );
  }
}
