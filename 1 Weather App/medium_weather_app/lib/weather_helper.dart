import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

// Fetch city suggestions
Future<List<Map<String, String>>> fetchCitySuggestions(String query) async {
  final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=10&language=en&format=json');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['results'] == null) {
      return [];
    }

    final suggestions = <Map<String, String>>[];

    for (var result in data['results']) {
      final city = result['name'] ?? "";
      final region = result['admin1'] ?? "";
      final country = result['country'] ?? "";
      final latitude = result['latitude'].toString();
      final longitude = result['longitude'].toString();

      if (city.isNotEmpty) {
        suggestions.add({
          'city': city,
          'region': region,
          'country': country,
          'latitude': latitude,
          'longitude': longitude,
        });
      } else {
        return Future.error(
            "Could not find weather results for the supplied location");
      }
    }

    return suggestions;
  } else {
    return Future.error(
        "Error: the service connection is lost. Please check your internet connection or try again later.");
  }
}
