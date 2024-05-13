// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/Dashboard/Screens/chart_details.dart';
import 'package:uniges/modules/Dashboard/services/chart_setting_controller.dart';
import 'package:uniges/modules/Dashboard/services/dashboard_service.dart';
import 'package:uniges/widgets/chartNavButton.dart';

class MyPieChartWidget extends StatefulWidget {
  final dynamic data;

  const MyPieChartWidget({Key? key, required this.data}) : super(key: key);

  @override
  _MyPieChartWidgetState createState() => _MyPieChartWidgetState();
}

class _MyPieChartWidgetState extends State<MyPieChartWidget>
    with AutomaticKeepAliveClientMixin {
  final DashboarsService dashboarsService = Get.find();
  final ChartSettingsController chartSettingsController =
      Get.put(ChartSettingsController());
  dynamic listChartPath;
  dynamic chartData;
  List<Map<String, String>> chartItemData = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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

  Future<void> getListChartsNavigation(String id) async {
    var getListChartNavigation =
        await dashboarsService.getListChartNavigation(id);
    setState(() {
      listChartPath = getListChartNavigation;
    });
  }

  Future<void> getchartData() async {
    chartData = await dashboarsService.getChartData(widget.data, 5);
    dynamicToList();
  }

  void onTapPieChart(
      FlTouchEvent? event, PieTouchResponse? touchResponse) async {
    if (event is FlTapUpEvent) {
      final pieTouchResponse = touchResponse as PieTouchResponse;

      await getListChartsNavigation(widget.data['id'].toString());

      final int touchedGroupIndex =
          pieTouchResponse.touchedSection!.touchedSectionIndex;

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getchartData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return (chartItemData.isEmpty)
              ? Expanded(child: Center(child: Text("Aucune donnée disponible")))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: const ScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        children: List.generate(chartItemData.length, (index) {
                          final item = chartItemData[index];
                          final valueX1 = item['value_x1'];

                          final colors = dashboarsService.pieColors[index];
                          return _buildChip(valueX1.toString(), colors);
                        }),
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: _PieChart(
                        chartItemData: chartItemData,
                        onTap: onTapPieChart,
                      ),
                    ),
                  ],
                );
        } else {
          return Expanded(child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }

  Widget _buildChip(String label, Color color) {
    return Chip(
        shape: LinearBorder.none,
        avatar: CircleAvatar(
          maxRadius: 6,
          backgroundColor: color,
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(0.0));
  }
}

double getPercentage(double number, List<double> numList) {
  double totalSum = numList.reduce((a, b) => a + b);
  if (totalSum != 0) {
    double percentage = (number / totalSum) * 100;
    return percentage;
  } else {
    return 0;
  }
}

class _PieChart extends StatelessWidget {
  final Function(FlTouchEvent, PieTouchResponse?) onTap;
  final List<Map<String, String>> chartItemData;

  _PieChart({required this.chartItemData, required this.onTap});
  final DashboarsService dashboarsService = Get.find();
  List<PieChartSectionData> generatePieChartSections() {
    List<PieChartSectionData> sections = [];
    var i = 0;
    double sum = 0;
    for (var item in chartItemData) {
      if (item.containsKey("value_y")) {
        sum += double.parse(item["value_y"]!);
      }
    }
    for (var data in chartItemData) {
      double value = double.parse(data['value_y']!.replaceAll(",", "."));
      double percent = (value / sum) * 100;
      sections.add(
        PieChartSectionData(
            badgePositionPercentageOffset: 1.2,
            badgeWidget: Card(
              child: Text("${percent.toStringAsFixed(2)} %"),
            ),
            color: dashboarsService.pieColors[i],
            value: value,
            title: data['value_x1'],
            radius: 50,
            showTitle: false),
      );
      i++;
    }
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> chartSections = generatePieChartSections();

    return PieChart(
      swapAnimationDuration: Duration(milliseconds: 150),
      swapAnimationCurve: Curves.linear,
      PieChartData(
          sections: chartSections,
          borderData: FlBorderData(show: true),
          centerSpaceRadius: 30,
          sectionsSpace: 0,
          pieTouchData: PieTouchData(touchCallback: onTap)),
    );
  }
}
