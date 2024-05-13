// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/Dashboard/services/dashboard_service.dart';

@immutable
class StackedBarChart extends StatefulWidget {
  final dynamic data;

  const StackedBarChart({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _StackedBarChartState createState() => _StackedBarChartState();
}

class _StackedBarChartState extends State<StackedBarChart>
    with AutomaticKeepAliveClientMixin {
  dynamic chartData;
  final DashboarsService dashboardService = Get.find();
  Map<String, Color> stringColorMap = {};
  List<List<dynamic>> extractedList = [];
  double maxY = 0;
  String? selectedLabel;

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

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
  }

  Future<void> getchartData() async {
    chartData = await dashboardService.getChartData(widget.data, 5);
    dynamicToStructList();
    maxY = calculateMaxY(extractedList);
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
        stringColorMap[value] = dashboardService.barColors[colorIndex];
        colorIndex++;
      }
    }

    int x = 0;

    for (var item in extractedList) {
      List<dynamic> innerList = item[1];
      List<BarChartRodData> stackItems = [];

      double fromY = 0.0;
      for (var innerItem in innerList) {
        String valueX2 = innerItem[0];
        dynamic y = innerItem[1];

        double value = y != null ? double.parse(y).toDouble() : 0.0;

        stackItems.add(
          BarChartRodData(
            borderRadius: BorderRadius.all(Radius.zero),
            fromY: fromY,
            toY: value + fromY,
            color: stringColorMap[valueX2]!,
            width: 20,
          ),
        );
        fromY += value;
      }
      seriesData.add(
        BarChartGroupData(
          x: x,
          groupVertically: true,
          barsSpace: 0.5,
          barRods: stackItems,
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

                return _buildChip(key.toString(), color!, this);
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
                          padding: const EdgeInsets.only(left: 20),
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

  Widget _buildChip(String label, Color color, _StackedBarChartState state) {
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
          ),
          backgroundColor: Colors.white,
          padding: EdgeInsets.all(8.0),
        ));
  }
}
