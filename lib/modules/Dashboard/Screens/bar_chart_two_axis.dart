// ignore_for_file: prefer_const_constructors

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/Dashboard/services/dashboard_service.dart';

class BarflChartTwoAxes extends StatefulWidget {
  final dynamic data;

  const BarflChartTwoAxes({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  _BarChartTwoAxesState createState() => _BarChartTwoAxesState();
}

class _BarChartTwoAxesState extends State<BarflChartTwoAxes> {
  Map<String, Color> stringColorMap = {};
  final DashboarsService dashboardController = Get.find();
  List<List<dynamic>> extractedList = [];
  double maxY = 0;

  dynamic chartData;
  List<Color> barColors = [
    const Color(0xFF176BA0),
    const Color(0xFF1AC9E6),
    const Color(0xFF1DE4BD),
    const Color(0xFF7D3AC1),
    const Color(0xFFDB4CB2),
    const Color(0xFFEA7369),
    const Color(0xFFC02323),
    const Color(0xFFEF7E32),
    const Color(0xFFEABD3B),
    const Color(0xFF176BA0),
    const Color(0xFF1AC9E6),
    const Color(0xFF1DE4BD),
  ];

  @override
  void initState() {
    super.initState();
  }

  void dynamicToStructList() {
    //converting data of charts //
    extractedList = chartData.map<List<dynamic>>((item) {
      final valueX1 = item['x1'] as String;
      final innerList = item['y1'].map<List<dynamic>>((innerItem) {
        final valueX2 = innerItem['x2'] as String;
        final y = innerItem['y1'] as String;
        return [valueX2, y];
      }).toList();

      return [valueX1, innerList];
    }).toList();
    extractedList = limitData(extractedList);
  }

  Future<void> getchartData() async {
    chartData = await dashboardController.getChartData(widget.data, 5);
    dynamicToStructList();
    maxY = calculateMaxY(extractedList);
  }

  double calculateMaxY(List<List<dynamic>> dataList) {
    double maxY = 0;

    for (List<dynamic> innerList in dataList) {
      double currentSum = 0;

      for (List<dynamic> pair in innerList[1]) {
        currentSum += double.parse(pair[1]);
      }

      if (currentSum > maxY) {
        maxY = currentSum;
      }
    }

    double roundedMaxY = maxY;
    if (maxY > 0) {
      int orderOfMagnitude = (log(maxY) / log(10)).floor();
      double magnitude = pow(10, orderOfMagnitude).toDouble();
      roundedMaxY = (maxY / magnitude).ceilToDouble() * magnitude;
    }

    return roundedMaxY;
  }

  List<List<dynamic>> limitData(List<List<dynamic>> dataList) {
    List<List<dynamic>> limitedList = [];
    if (dataList.length > 5) dataList.length = 5;
    for (final item in dataList) {
      final key = item[0];
      final values = item[1] as List<dynamic>;

      if (values.length > 4) {
        values.length = 4;
      }

      limitedList.add([key, values]);
    }

    return limitedList;
  }

  List<String> convertToList(String inputString) {
    List<String> docList =
        inputString.split(',').map((item) => item.trim()).toList();
    return docList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getchartData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return (extractedList.isEmpty)
                ? Expanded(
                    child: Center(child: Text("Aucune donnée disponible")))
                : _buildBarChart(extractedList);
          } else {
            return const Expanded(
                child: Center(child: CircularProgressIndicator()));
          }
        });
  }

  List<BarChartGroupData> _createSeriesData(List<List<dynamic>> extractedList) {
    List<BarChartGroupData> seriesData = [];

    Set<String> uniqueStrings = {};

    for (final item in extractedList) {
      final values = item[1] as List<dynamic>;

      for (final valueItem in values) {
        final stringValue = valueItem[0] as String;
        uniqueStrings.add(stringValue);
      }
      int colorIndex = 0;
      for (final value in uniqueStrings) {
        stringColorMap[value] = barColors[colorIndex % barColors.length];
        colorIndex++;
      }
    }

    int x = 0;

    for (var item in extractedList) {
      List<dynamic> innerList = item[1];
      List<BarChartRodData> rodData = [];
      int i = 0;
      for (var innerItem in innerList) {
        i += 1;
        String valueX2 = innerItem[0];
        dynamic y = innerItem[1];

        rodData.add(
          BarChartRodData(
            toY: double.parse(y).toDouble(),
            color: stringColorMap[valueX2],
            width: 15,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(0)),
          ),
        );
      }

      seriesData.add(
        BarChartGroupData(
          x: x,
          barsSpace: 0.5,
          barRods: rodData,
        ),
      );
      x += 1;
    }

    return seriesData;
  }

  Widget _buildBarChart(List<List<dynamic>> extractedList) {
    List<BarChartGroupData> seriesData = _createSeriesData(extractedList);
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(3),
              shrinkWrap: true,
              physics: ScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              children: List.generate(stringColorMap.length, (index) {
                final key = stringColorMap.keys.elementAt(index);
                final color = stringColorMap[key];

                return _buildChip(key.toString(), color!);
              }),
            ),
          ),
          SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: AspectRatio(
              aspectRatio: 2,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  borderData: FlBorderData(
                    border: const Border(
                      bottom: BorderSide(),
                      left: BorderSide(),
                    ),
                  ),
                  backgroundColor: Colors.white,
                  gridData: FlGridData(
                    show: true,
                    checkToShowHorizontalLine: (value) => value % 100 == 0,
                    getDrawingHorizontalLine: (value) => FlLine(
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  alignment: BarChartAlignment.spaceEvenly,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, t) {
                        double width = (MediaQuery.of(context).size.width) /
                            chartData.length;
                        return Container(
                          padding: const EdgeInsets.only(left: 10),
                          width: width * 0.8,
                          child: Text(
                            extractedList[value.toInt()][0]!,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        );
                      },
                    )),
                    leftTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 50)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                      showTitles: false,
                      reservedSize: 10,
                    )),
                  ),
                  barGroups: seriesData,
                ),
                swapAnimationDuration: Duration(milliseconds: 150),
                swapAnimationCurve: Curves.linear,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildChip(String label, Color color) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Chip(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      avatar: CircleAvatar(
        backgroundColor: color,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.white,
      padding: EdgeInsets.all(8.0),
    ),
  );
}
