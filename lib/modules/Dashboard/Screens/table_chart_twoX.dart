// ignore_for_file: prefer_const_constructors

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/Dashboard/services/dashboard_service.dart';

class tableChartDoubleX extends StatefulWidget {
  final dynamic data;

  const tableChartDoubleX({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  _tableChartDoubleXState createState() => _tableChartDoubleXState();
}

class _tableChartDoubleXState extends State<tableChartDoubleX> {
  Map<String, Color> stringColorMap = {};
  final DashboarsService dashboardController = Get.find();
  List<List<dynamic>> extractedList = [];
  double maxY = 0;
  List<List<dynamic>> limitedData = [];

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

    print(extractedList);
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
                : Container(
                    width: double.maxFinite,
                    color: Colors.grey[200],
                    child: _buildAxisTable(extractedList));
          } else {
            return const Expanded(
                child: Center(child: CircularProgressIndicator()));
          }
        });
  }

  Widget _buildAxisTable(var data) {
    return SingleChildScrollView(
      child: DataTable(
        border: TableBorder.all(),
        dataRowMinHeight: 100,
        dataRowMaxHeight: 150,
        columns: [
          DataColumn(label: Text(widget.data['UnigesBI_fieldx'].split(',')[0])),
          DataColumn(
            label: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.data['UnigesBI_fieldx'].split(',')[1]),
                VerticalDivider(),
                Text(widget.data['UnigesBI_fieldy']),
              ],
            ),
          )
        ],
        rows: data.map<DataRow>((entry) {
          return DataRow(
            cells: [
              DataCell(Text(entry[0])),
              DataCell(_buildTable(entry[1])),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable(List<List<dynamic>> values) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: values.map<Widget>((item) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item[0].toString()),
                    VerticalDivider(),
                    Text(item[1].toString()),
                  ],
                ),
                Divider(),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
