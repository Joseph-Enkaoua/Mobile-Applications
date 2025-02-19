import 'package:flutter/material.dart';
import 'package:medium_weather_app/element_helper.dart';

class CurrentView extends StatelessWidget {
  const CurrentView(
      {super.key,
      required this.location,
      required this.currentWeather,
      required this.errorMessage});

  final String errorMessage;
  final Map<String, String> location;
  final Map<String, String> currentWeather;

  Widget getData(BuildContext context) {
    if (errorMessage != "") {
      return ErrorCard(message: errorMessage);
    }
    if (location['city'] != '' && location['city'] != null) {
      return Column(children: [
        BodyTitle(location: location),
        Expanded(
          child: Card.filled(
            color: Theme.of(context).colorScheme.onPrimary,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    currentWeather['temp'] ?? 'N/A',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        WeatherDescriptionMaps.getWeatherDescription(
                            "${currentWeather['weathercode']}"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: WeatherDescriptionMaps(
                          weatherCode: "${currentWeather['weathercode']}",
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.air,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        currentWeather['windspeed'] ?? 'N/A',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ]);
    } else {
      return MessageCard(
          message: 'Please choose location to show the current weather at');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: getData(context),
    );
  }
}
