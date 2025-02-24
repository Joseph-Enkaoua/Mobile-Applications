import 'package:flutter/material.dart';
import 'package:medium_weather_app/element_helper.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyyView extends StatelessWidget {
  const WeeklyyView(
      {super.key,
      required this.location,
      required this.weeklyWeather,
      required this.errorMessage});

  final String errorMessage;
  final Map<String, String> location;
  final List<Map<String, double>> weeklyWeather;

  double getMinTemperature() {
    return weeklyWeather
        .map((entry) => entry['minTemp']!)
        .reduce((a, b) => a < b ? a : b);
  }

  double getMaxTemperature() {
    return weeklyWeather
        .map((entry) => entry['maxTemp']!)
        .reduce((a, b) => a > b ? a : b);
  }

  List<FlSpot> buildChartData(bool isMin) {
    List<FlSpot> list = [];

    for (var entry in weeklyWeather.asMap().entries) {
      int index = entry.key;
      var data = entry.value;

      double? temp = isMin ? data['minTemp'] : data['maxTemp'];

      if (temp != null && temp.isFinite) {
        list.add(FlSpot(index.toDouble(), temp));
      }
    }

    return list;
  }

  List<Widget> weeklyForecastList() {
    List<Widget> list = [];

    list.addAll(weeklyWeather.map(
      (entry) => Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '${entry['date']}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              '${entry['minTemp']}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 90,
            child: Text(
              '${entry['maxTemp']}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 18),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                WeatherDescriptionMaps.getWeatherDescription(
                    "${entry['weathercode']}"),
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.clip,
              ),
            ),
          ),
        ],
      ),
    ));

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
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "Temperatures this week",
                      style: TextStyle(
                          fontSize: width * 0.03 + 10, color: Colors.blue),
                    ),
                  ),
                  axisNameSize: height * 0.22,
                ),
                rightTitles: AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    interval:
                        getMaxTemperature() - getMinTemperature() > 12 ? 3 : 1,
                    showTitles: true,
                    reservedSize: width * 0.095,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value > getMaxTemperature() + 0.5 ||
                          value < getMinTemperature() - 0.5) {
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
                  axisNameSize: width * 0.1,
                  axisNameWidget: Padding(
                    padding: EdgeInsets.only(
                        top: 0, bottom: 11, left: width * 0.095),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var entry in weeklyWeather)
                          getDate(entry['day']!, entry['month']!,
                              size: width * 0.028),
                      ],
                    ),
                  ),
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),
              ),
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
                  spots: buildChartData(false),
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow,
                      Colors.orangeAccent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  dotData: FlDotData(
                    show: false,
                  ),
                ),
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
                  spots: buildChartData(true),
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightGreen,
                      Colors.lightBlue,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
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

  Text getDate(double day, double month, {double size = 12}) {
    String date;

    if (day < 10) {
      date = "0${day.toInt()}";
    } else {
      date = "${day.toInt()}";
    }
    if (month < 10) {
      date += "/0${month.toInt()}";
    } else {
      date += "/${month.toInt()}";
    }
    return Text(
      date,
      style: TextStyle(color: Colors.blueGrey, fontSize: size),
    );
  }

  List<Container> buildCardList(BuildContext c, double h, double w) {
    List<Container> list = [];

    list.addAll(weeklyWeather.map(
      (entry) => Container(
        width: h * 0.5,
        height: w * 0.38,
        color: Theme.of(c).colorScheme.onPrimary,
        margin: EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            getDate(entry['day']!, entry['month']!),
            WeatherDescriptionMaps(
              weatherCode: entry['weathercode']!.truncate().toString(),
              size: 32,
              color: Colors.lightBlueAccent,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${entry['maxTemp']!.toInt()}°C",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                ),
                Text(
                  " max",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${entry['minTemp']!.toInt()}°C",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.lightGreen, fontSize: 12),
                ),
                Text(
                  " min",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.lightGreen, fontSize: 12),
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
    return Center(
      child:
          Padding(padding: const EdgeInsets.all(12.0), child: getData(context)),
    );
  }
}
