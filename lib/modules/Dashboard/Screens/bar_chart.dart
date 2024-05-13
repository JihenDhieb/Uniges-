// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/Dashboard/Screens/chart_details.dart';
import 'package:uniges/modules/Dashboard/services/chart_setting_controller.dart';
import 'package:uniges/modules/Dashboard/services/dashboard_service.dart';
import 'package:uniges/widgets/chartNavButton.dart';

class MyBarChartWidget extends StatefulWidget {
  final dynamic data;
  final bool isDetail;
  final bool isVertical;
  const MyBarChartWidget({
    Key? key,
    required this.isDetail,
    required this.isVertical,
    required this.data,
  }) : super(key: key);

  @override
  _MyBarChartWidgetState createState() => _MyBarChartWidgetState();
}

class _MyBarChartWidgetState extends State<MyBarChartWidget>
    with AutomaticKeepAliveClientMixin {
  final DashboarsService dashboarsService = Get.find();
  final ChartSettingsController chartSettingsController =
      Get.put(ChartSettingsController());
  dynamic listChartPath;
  dynamic chartData;
  List<Map<String, String>> chartItemData = [];
  @override
  void initState() {
    super.initState();
    getchartData();
  }

  @override
  bool get wantKeepAlive => true;

  void dynamicToList() {
    //converting dynamic data of charts to List<Map<String, String>> //

    chartItemData.clear();
    if (chartData != null) {
      for (var item in chartData) {
        if (item is Map<String, dynamic>) {
          Map<String, String> stringMap = {};
          item.forEach((key, value) {
            if (value is String) {
              stringMap[key] = value;
            } else {
              stringMap[key] = value.toString();
            }
          });
          chartItemData.add(stringMap);
        }
      }
    }
  }

  Future<void> getListChartsNavigation(String id) async {
    var getListChartNavigation =
        await dashboarsService.getListChartNavigation(id);
    setState(() {
      listChartPath = getListChartNavigation;
    });
  }

  double calculateMaxY() {
    if (chartItemData.isEmpty) return 0;

    double maxY = double.negativeInfinity;

    for (final item in chartItemData) {
      final valueY =
          double.parse(item['value_y'].toString().replaceAll(",", "."));
      if (valueY > maxY) {
        maxY = valueY;
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

  Future<void> getchartData() async {
    chartData = await dashboarsService.getChartData(widget.data, 5);
    dynamicToList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getchartData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return (chartItemData.isEmpty)
              ? Expanded(child: Center(child: Text("Aucune donnée disponible")))
              : Obx(() => SizedBox(
                    height: 250,
                    child: AspectRatio(
                      aspectRatio: (widget.isDetail)
                          ? chartSettingsController.aspectRatio.value
                          : 16 / 9,
                      child: RotatedBox(
                        quarterTurns: (widget.isVertical) ? 0 : 1,
                        child: BarChart(
                          BarChartData(
                            maxY: calculateMaxY(),
                            borderData: FlBorderData(
                                border: const Border(
                                    bottom: BorderSide(), left: BorderSide())),
                            backgroundColor: Colors.white,
                            gridData: FlGridData(
                              show: true,
                              checkToShowHorizontalLine: (value) =>
                                  value % 100 == 00,
                              getDrawingHorizontalLine: (value) => FlLine(
                                strokeWidth: 1,
                              ),
                            ),
                            alignment: BarChartAlignment.spaceEvenly,
                            barTouchData: BarTouchData(
                              touchCallback: onTapBarChart,
                              touchTooltipData: BarTouchTooltipData(
                                fitInsideVertically: true,
                                tooltipBorder: BorderSide(width: 0.1),
                                rotateAngle: (widget.isVertical) ? 0 : -90,
                                tooltipBgColor: Colors.grey[200],
                                tooltipMargin: 0,
                                tooltipPadding: EdgeInsets.all(2),
                                getTooltipItem: (
                                  BarChartGroupData group,
                                  int groupIndex,
                                  BarChartRodData rod,
                                  int rodIndex,
                                ) {
                                  return BarTooltipItem(
                                    "${chartItemData[groupIndex]['value_x1'].toString()} \n${rod.toY} ",
                                    TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 10,
                                  getTitlesWidget: (value, t) => Text(''),
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  reservedSize: 20,
                                  showTitles: true,
                                  getTitlesWidget: (value, t) => Text(''),
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    reservedSize:
                                        (widget.isVertical) ? 30 : 100,
                                    showTitles: chartSettingsController
                                        .isXAxisVisible.value,
                                    getTitlesWidget: (value, t) {
                                      String text = chartItemData[value.toInt()]
                                          ['value_x1']!;

                                      return RotatedBox(
                                        quarterTurns:
                                            (widget.isVertical) ? 0 : -1,
                                        child: Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Center(
                                            child: Text(
                                              softWrap: false,
                                              overflow: TextOverflow.fade,
                                              text,
                                              style: TextStyle(
                                                  // fontSize: textSize,
                                                  //fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: chartSettingsController
                                      .isYAxisVisible.value,
                                  getTitlesWidget: (value, t) => RotatedBox(
                                      quarterTurns:
                                          (widget.isVertical) ? 0 : -1,
                                      child: Text(formatNumber(value))),
                                  reservedSize: (widget.isVertical) ? 50 : 22,
                                ),
                              ),
                            ),
                            barGroups: chartItemData
                                .asMap()
                                .map((index, data) => MapEntry(
                                      index,
                                      BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          (chartSettingsController
                                                  .isRainbow.value)
                                              ? BarChartRodData(
                                                  color: chartSettingsController
                                                      .barColors[index],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.zero),
                                                  toY: double.parse(
                                                      data['value_y']
                                                          .toString()
                                                          .replaceAll(
                                                              ",", ".")),
                                                  width: chartSettingsController
                                                      .barWidth.value,
                                                )
                                              : BarChartRodData(
                                                  gradient:
                                                      chartSettingsController
                                                          .selectedGradient
                                                          .value,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.zero),
                                                  toY: double.parse(
                                                      data['value_y']
                                                          .toString()
                                                          .replaceAll(
                                                              ",", ".")),
                                                  width: chartSettingsController
                                                      .barWidth.value,
                                                ),
                                        ],
                                      ),
                                    ))
                                .values
                                .toList(),
                          ),
                          swapAnimationDuration: Duration(milliseconds: 150),
                          swapAnimationCurve: Curves.linear,
                        ),
                      ),
                    ),
                  ));
        } else {
          return Expanded(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  String formatNumber(double number) {
    if (number >= 1e9) {
      double result = number / 1e9;
      return '${result.toStringAsFixed(1)}B';
    } else if (number >= 1e6) {
      double result = number / 1e6;
      return '${result.toStringAsFixed(1)}M';
    } else if (number >= 1e3) {
      double result = number / 1e3;
      return '${result.toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  void onTapBarChart(
      FlTouchEvent? event, BarTouchResponse? touchResponse) async {
    if (event is FlTapUpEvent) {
      final barTouchResponse = touchResponse as BarTouchResponse;

      if (barTouchResponse.spot != null &&
          barTouchResponse.spot!.touchedBarGroupIndex >= 0) {
        await getListChartsNavigation(widget.data['id'].toString());
        final touchedGroupIndex = barTouchResponse.spot!.touchedBarGroupIndex;

        if (touchedGroupIndex >= 0) {
          if (listChartPath.length > 0) {
            String value = chartData[touchedGroupIndex]['value_x1']!;
            String filterStatement =
                "${widget.data['UnigesBI_fieldx']} ='$value'";
            Get.dialog(AlertDialog(
              title: const Text(
                'Aller a',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: listChartPath.map<Widget>((chartData) {
                  return buildButtonChart(
                    () {
                      var _copyChartData = json.decode(json.encode(chartData));
                      if (_copyChartData['UnigesBI_filter'] == null ||
                          _copyChartData['UnigesBI_filter'] == "") {
                        _copyChartData['UnigesBI_filter'] = filterStatement;
                      } else {
                        _copyChartData['UnigesBI_filter'] +=
                            " and $filterStatement";
                      }
                      Get.back();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChartDetails(
                                  data: _copyChartData,
                                  key: UniqueKey(),
                                )),
                      );
                    },
                    chartData['UnigesBI_Titre'].toString(),
                    chartData['UnigesBI_ChartType'].toString(),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    'Annuler',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ));
          }
        }
      }
    }
  }
}
