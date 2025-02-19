import 'package:flutter/material.dart';
import 'package:medium_weather_app/weather_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar(
      {super.key,
      required this.setLocation,
      required this.fetchWeatherData,
      required this.setErrorMessage});

  final Function(String city, String region, String country) setLocation;
  final Function(String longitude, String latitude) fetchWeatherData;
  final Function(String message) setErrorMessage;

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 25);
}

class _TopBarState extends State<TopBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> reverseGeocoding(String latitude, String longitude) async {
    // API key is safe to be exposed to public.
    final url =
        'https://geocode.maps.co/reverse?lat=$latitude&lon=$longitude&api_key=679807c732333469974320jqw5f420f';

    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        String city = responseData['address']['town'].toString();
        if (city == "null") {
          city = responseData['address']['city'].toString();
        }
        final String region = responseData['address']['state'].toString();
        final String country = responseData['address']['country'].toString();
        widget.setLocation(city, region, country);
        widget.setErrorMessage("");
      } else {
        debugPrint(
            "Error during reverse geocoding. Response status ${response.statusCode}");
        widget.setErrorMessage(
            "Error: the service connection is lost. Please check your internet connection or try again later");
      }
    } catch (e) {
      debugPrint("$e");
      widget.setErrorMessage(
          "Error: the service connection is lost. Please check your internet connection or try again later");
    }
  }

  // Fetch GPS location
  Future<void> fetchLocation() async {
    FocusScope.of(context).unfocus();
    try {
      _searchController.clear();
      setState(() {});

      final locationData = await determinePosition();
      final String latitude = locationData.latitude.toString();
      final String longitude = locationData.longitude.toString();

      reverseGeocoding(latitude, longitude);
      widget.fetchWeatherData(latitude, longitude);
    } catch (e) {
      debugPrint("$e");
      widget.setErrorMessage("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(25.0),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Expanded(
                  child: Autocomplete<Map<String, String>>(
                    displayStringForOption: (option) => '',
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text == '') {
                        return const Iterable<Map<String, String>>.empty();
                      }
                      try {
                        final suggestion =
                            await fetchCitySuggestions(textEditingValue.text);
                        return suggestion;
                      } catch (e) {
                        debugPrint("$e");
                        widget.setErrorMessage(
                            "Error: the service connection is lost. Please check your internet connection or try again later");
                        return const Iterable<Map<String, String>>.empty();
                      }
                    },

                    // Custom builder for the suggestions overlay
                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<Map<String, String>> onSelected,
                        Iterable<Map<String, String>> options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 32),
                          child: Material(
                            color: Colors.blue[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(),
                              child: ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount:
                                    options.length > 5 ? 5 : options.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 1),
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(option),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_city),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Expanded(
                                            child: RichText(
                                              text: TextSpan(
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black),
                                                children: [
                                                  TextSpan(
                                                    text: option['city'],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        ', ${option['region']}, ${option['country']}',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },

                    // When a suggestion is selected.
                    onSelected: (Map<String, String> selection) {
                      FocusScope.of(context).unfocus();
                      widget.setLocation('${selection['city']}',
                          '${selection['region']}', '${selection['country']}');
                      widget.fetchWeatherData('${selection['latitude']}',
                          '${selection['longitude']}');

                      if ('${selection['latitude']}' != "") {
                        widget.setErrorMessage("");
                      }
                    },

                    // Field builder for the text field.
                    fieldViewBuilder: (context, textEditingController,
                        focusNode, onFieldSubmitted) {
                      _searchController.text = textEditingController.text;
                      _searchController.selection =
                          textEditingController.selection;

                      _searchController.addListener(() {
                        if (_searchController.text !=
                            textEditingController.text) {
                          textEditingController.text = _searchController.text;
                          textEditingController.selection =
                              _searchController.selection;
                        }
                      });

                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onSubmitted: (String value) async {
                          FocusScope.of(context).unfocus();
                          if (value.trim().isEmpty) {
                            return;
                          }

                          try {
                            final suggestions =
                                await fetchCitySuggestions(value);

                            if (suggestions.isNotEmpty) {
                              final bestMatch = suggestions.first;
                              _searchController.text =
                                  "${bestMatch['city']}, ${bestMatch['region']}" ==
                                          ", "
                                      ? _searchController.text
                                      : "${bestMatch['city']}, ${bestMatch['region']}";

                              widget.setLocation(
                                  '${bestMatch['city']}',
                                  '${bestMatch['region']}',
                                  '${bestMatch['country']}');
                              widget.fetchWeatherData(
                                  '${bestMatch['latitude']}',
                                  '${bestMatch['longitude']}');
                              widget.setErrorMessage("");
                            } else {
                              widget.setErrorMessage(
                                  "Could not find results for the supplied address or coordinates");
                            }
                          } catch (e) {
                            widget.setErrorMessage(
                                "Error fetching location. Please try again");
                          }
                          textEditingController.clear();
                        },
                        style: TextStyle(color: Colors.grey),
                        decoration: InputDecoration(
                          hintText: "Search location",
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 15.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.near_me),
                  onPressed: fetchLocation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
