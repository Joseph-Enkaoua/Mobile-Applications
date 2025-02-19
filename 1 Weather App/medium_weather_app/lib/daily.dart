import 'package:flutter/material.dart';
import 'package:medium_weather_app/element_helper.dart';
import 'package:fl_chart/fl_chart.dart';

class DailyView extends StatelessWidget {
  const DailyView(
      {super.key,
      required this.location,
      required this.dailyWeather,
      required this.errorMessage});

  final String errorMessage;
  final Map<String, String> location;
  final List<Map<String, double>> dailyWeather;

  double getMinTemperature() {
    return dailyWeather
        .map((entry) => entry['temp']!)
        .reduce((a, b) => a < b ? a : b);
  }

  double getMaxTemperature() {
    return dailyWeather
        .map((entry) => entry['temp']!)
        .reduce((a, b) => a > b ? a : b);
  }

  List<FlSpot> buildChartData() {
    List<FlSpot> list = [];

    for (var entry in dailyWeather) {
      double? hour = entry['hour'];
      double? temp = entry['temp'];

      if (hour != null && temp != null && hour.isFinite && temp.isFinite) {
        list.add(FlSpot(hour, temp));
      }
    }

    return list;
  }

  Widget getGraph() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        if (width == double.infinity || height == double.infinity) {
          width = MediaQuery.of(context).size.width * 0.85;
          height = MediaQuery.of(context).size.height * 0.29;
        }

        return SizedBox(
          width: width,
          height: width * 0.6 + 80,
          child: LineChart(
            LineChartData(
              minY: getMinTemperature() - 1,
              maxY: getMaxTemperature() + 1,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                  topTitles: AxisTitles(
                    axisNameWidget: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Temperatures today",
                        style: TextStyle(
                            fontSize: width * 0.03 + 10, color: Colors.white),
                      ),
                    ),
                    axisNameSize: height * 0.22,
                  ),
                  rightTitles: AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      interval: getMaxTemperature() - getMinTemperature() > 12
                          ? 3
                          : 1,
                      showTitles: true,
                      reservedSize: width * 0.095,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value > getMaxTemperature() + 0.8 ||
                            value < getMinTemperature() - 0.9) {
                          return Container();
                        }
                        return Text(
                          "${value.round()}°c",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.orange, fontSize: width * 0.028),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          reservedSize: width * 0.1,
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value == 23 || value % 5 != 0) {
                              return Container();
                            } else if (value < 10) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: 4, bottom: 4, left: width * 0.095),
                                child: Text(
                                  "0${value.round()}:00",
                                  style: TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: width * 0.03),
                                ),
                              );
                            }
                            return Padding(
                              padding: EdgeInsets.only(
                                  top: 4, bottom: 4, left: width * 0.095),
                              child: Text(
                                "${value.round()}:00",
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: width * 0.03),
                              ),
                            );
                          }))),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.amberAccent.withAlpha(40),
                  ),
                  aboveBarData: BarAreaData(
                    show: true,
                    color: Colors.lightBlue.withAlpha(40),
                  ),
                  spots: buildChartData(),
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightGreen,
                      Colors.yellow,
                      Colors.orange,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  dotData: FlDotData(
                    show: false,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Text getHour(double time) {
    if (time < 10) {
      return Text(
        "0${time.toInt()}:00",
        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
      );
    }
    return Text(
      "${time.toInt()}:00",
      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
    );
  }

  List<Container> buildCardList(BuildContext c, double h, double w) {
    List<Container> list = [];

    list.addAll(dailyWeather.map(
      (entry) => Container(
        width: h * 0.5,
        height: w * 0.38,
        color: Theme.of(c).colorScheme.onPrimary,
        margin: EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            getHour(entry['hour']!),
            WeatherDescriptionMaps(
              weatherCode: entry['weathercode']!.truncate().toString(),
              size: 32,
              color: Colors.lightBlueAccent,
            ),
            Text(
              "${entry['temp']}°C",
              style: TextStyle(color: Theme.of(c).colorScheme.secondary),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.air, size: 12, color: Colors.black54),
                Text(
                  "${entry['windspeed']}km/h",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    ));

    return list;
  }

  Widget getCardlist() {
    final ScrollController scrollController = ScrollController();

    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

        if (width == double.infinity || height == double.infinity) {
          width = MediaQuery.of(context).size.width * 0.50 + 220;
          height = MediaQuery.of(context).size.height * 0.22 + 25;
        }

        return Scrollbar(
          controller: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: buildCardList(context, height, width),
            ),
          ),
        );
      },
    );
  }

  Widget getData(BuildContext context) {
    if (errorMessage != "") {
      return ErrorCard(message: errorMessage);
    }
    if (location['city'] != '' && location['city'] != null) {
      return Column(
        children: [
          BodyTitle(location: location),
          Expanded(
            child: Card.filled(
              color: Theme.of(context).colorScheme.onPrimary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: getGraph(),
                  ),
                  getCardlist(),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return MessageCard(
          message: 'Please choose location to show the daily weather at');
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
