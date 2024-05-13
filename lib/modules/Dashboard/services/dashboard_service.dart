// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:uniges/constant/app_constant.dart';
import 'package:uniges/main.dart';
import 'package:uniges/services/uniges_service.dart';

class DashboarsService extends GetxController {
  dynamic listeDataSet;
  dynamic dataStruct;
  Set<String> operationsList = {'=', '>', '<'};
  List<dynamic> listeOperations = [
    {'operation_code': 'sum', 'operation_name': 'somme'},
    {'operation_code': 'count', 'operation_name': 'count'},
    {'operation_code': 'avg', 'operation_name': 'moyenne'},
    {'operation_code': 'none', 'operation_name': 'Vide'}
  ];
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
  List<Color> pieColors = [
    const Color(0xFF176BA0),
    const Color(0xFF1AC9E6),
    const Color(0xFF1DE4BD),
    const Color(0xFF7D3AC1),
    const Color(0xFFDB4CB2),
    const Color(0xFFEA7369),
    const Color(0xFFC02323),
    const Color(0xFFEF7E32),
    const Color(0xFFEABD3B),
  ];

  Future<void> initializeService() async {
    await getData();
    await organizeData(listeDataSet);
  }

  Future<void> getData() async {
    listeDataSet = await UnigesService.tableRecherche("listDataSet");
  }

  List<String> convertToList(String inputString) {
    List<String> docList =
        inputString.split(',').map((item) => item.trim()).toList();
    return docList;
  }

  Future<List<dynamic>?> getChartData(dynamic chart, int? nbre) async {
    try {
      dio.options.headers = AppConstants().jsonHEADERS;
      var url = '${AppConstants().baseUrl}/bi/getChartData';
      dynamic res;
      var fieldX = convertToList(chart['UnigesBI_fieldx']);
      if (chart['UnigesBI_filter'] == null ||
          chart['UnigesBI_filter'] == "null" ||
          chart['UnigesBI_filter'] == "") {
        res = await dio.post(url, data: {
          "field_x": fieldX,
          "field_y": chart['UnigesBI_fieldy'],
          "dataset": chart['UnigesBI_Dataset']
        });
      } else {
        res = await dio.post(url, data: {
          "field_x": fieldX,
          "field_y": chart['UnigesBI_fieldy'],
          "dataset": chart['UnigesBI_Dataset'],
          "filter": chart['UnigesBI_filter'],
        });
      }

      if (res.statusCode < 300) {
        var jsonResponse = res.data;
        if (nbre == null) {
          return jsonResponse;
        } else {
          return jsonResponse.length > nbre
              ? jsonResponse.sublist(0, nbre)
              : jsonResponse;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> organizeData(dynamic data) async {
    var groupedData = {};

    for (final entry in data) {
      final parent1 = entry['UnigesBI_Parent1'];
      final parent2 = entry['UnigesBI_Parent2'];
      final id = entry['id'];

      if (!groupedData.containsKey(parent1)) {
        groupedData[parent1] = {};
      }

      if (!groupedData[parent1]!.containsKey(parent2)) {
        groupedData[parent1]![parent2] = [];
      }

      groupedData[parent1]![parent2]!.add(id);
    }
    dataStruct = groupedData;
  }

  Map<String, dynamic>? getChartById(String id) {
    for (final chart in listeDataSet) {
      if (chart['id'].toString() == id) {
        return chart;
      }
    }
    return null;
  }

  Future<List<dynamic>> getFields(String dataset) async {
    final baseUrl =
        '${AppConstants().baseUrl}/recherche/TbRecherche?param=$dataset';

    try {
      var response = await dio.get(baseUrl);

      if (response.statusCode == 200) {
        return jsonDecode(response.data)['TableRD'];
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }

    return [];
  }

  Future<List> getListChartNavigation(String idChart) async {
    dynamic listIdsChart = await getChartIdsNavigation(idChart);
    //dynamic listIdsChart = ["4", "7", "8"];
    final List<dynamic> charts = [];
    for (final id in listIdsChart) {
      try {
        dynamic chart = getChartById(id);
        charts.add(chart);
      } catch (e) {
        print(e);
      }
    }
    return charts;
  }

  Future<List<int>> getChartIdsNavigation(String fromId) async {
    var data = await UnigesService.tableRecherche("UnigesBINav");
    if (data != null) {
      final dataList = List<Map<String, dynamic>>.from(data);

      final mappedList = dataList
          .where((item) => item["UnigesBI_fromId"] == fromId)
          .map<int>((item) => item["UnigesBI_toId"])
          .toList();

      return mappedList;
    } else {
      Fluttertoast.showToast(
        msg: "Aucun navigation trouvé",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 231, 131, 131),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      throw Exception('Failed to fetch data');
    }
  }
}
