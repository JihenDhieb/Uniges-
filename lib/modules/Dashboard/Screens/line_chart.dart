import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/Dashboard/Screens/chart_details.dart';
import 'package:uniges/modules/Dashboard/services/chart_setting_controller.dart';
import 'package:uniges/modules/Dashboard/services/dashboard_service.dart';
import 'package:uniges/widgets/chartNavButton.dart';

class MyLineChartWidget extends StatefulWidget {
  final dynamic data;
  const MyLineChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyLineChartWidgetState createState() => _MyLineChartWidgetState();
}

class _MyLineChartWidgetState extends State<MyLineChartWidget>
    with AutomaticKeepAliveClientMixin {
  final DashboarsService dashboarsService = Get.find();
  final ChartSettingsController chartSettingsController =
      Get.put(ChartSettingsController());
  dynamic chartData;
  dynamic listChartPath;
  List<Map<String, String>> chartItemData = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getchartData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return (chartItemData.isEmpty)
              ? const Expanded(
                  child: Center(child: Text("Aucune donnée disponible")))
              : Obx(() => SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: AspectRatio(
                        aspectRatio: 2,
                        child: LineChart(
                          LineChartData(
                            maxY: calculateMaxY(),
                            minY: 0,
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                bottom: BorderSide(),
                                left: BorderSide(),
                              ),
                            ),
                            backgroundColor: Colors.white,
                            lineTouchData: LineTouchData(
                                touchTooltipData: const LineTouchTooltipData(
                                    tooltipBgColor: Colors.white),
                                touchCallback: onTapLineChart),
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              drawHorizontalLine: true,
                              //horizontalInterval: 10,
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                getTitlesWidget: (value, t) {
                                  String text =
                                      chartItemData[value.toInt()]['value_x1']!;
                                  double width =
                                      (MediaQuery.of(context).size.width) /
                                          chartItemData.length;
                                  return Container(
                                    padding: const EdgeInsets.only(left: 10),
                                    width: width * 0.8,
                                    child: Center(
                                      child: Text(
                                        softWrap: false,
                                        overflow: TextOverflow.fade,
                                        text,
                                        style: const TextStyle(
                                            // fontSize: dashboardController.textSize.value,
                                            //fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  );
                                },
                                showTitles: true,
                                interval: 1,
                              )),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                showTitles: false,
                                interval: 1,
                              )),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                reservedSize: 30,
                                showTitles: true,
                                getTitlesWidget: (value, meta) =>
                                    const Text(""),
                              )),
                              leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(
                                reservedSize: 50,
                                //interval: 20,
                                showTitles: true,
                              )),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: chartItemData
                                    .asMap()
                                    .map((index, data) {
                                      String value = data['value_y']!
                                          .toString()
                                          .replaceAll(",", ".");
                                      return MapEntry(
                                        index,
                                        FlSpot(index.toDouble(),
                                            double.parse(value)),
                                      );
                                    })
                                    .values
                                    .toList(),
                                isCurved: true,
                                belowBarData: BarAreaData(
                                    show: true,
                                    gradient: chartSettingsController
                                        .selectedGradient.value),
                                curveSmoothness: 0.3,
                                gradient: chartSettingsController
                                    .selectedGradient.value,
                                color: Colors.blue,
                                barWidth: 6,
                              ),
                            ],
                          ),
                        )),
                  ));
        } else {
          return const Expanded(
              child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Future<void> getListChartsNavigation(String id) async {
    var getListChartNavigation =
        await dashboarsService.getListChartNavigation(id);
    setState(() {
      listChartPath = getListChartNavigation;
    });
  }

  void onTapLineChart(
      FlTouchEvent? event, LineTouchResponse? touchResponse) async {
    if (event is FlTapUpEvent) {
      final barTouchResponse = touchResponse as LineTouchResponse;

      await getListChartsNavigation(widget.data['id'].toString());

      final int touchedGroupIndex = barTouchResponse.lineBarSpots![0].spotIndex;

      if (listChartPath.length > 0) {
        String value = chartData[touchedGroupIndex]['value_x1']!;
        String filterStatement = "${widget.data['UnigesBI_fieldx']} ='$value'";
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
