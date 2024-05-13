import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/Dashboard/services/dashboard_service.dart';

class TableChart extends StatefulWidget {
  final dynamic data;

  const TableChart({super.key, required this.data});
  @override
  // ignore: library_private_types_in_public_api
  _TableChartState createState() => _TableChartState();
}

class _TableChartState extends State<TableChart> {
  final DashboarsService settingsService = Get.find();
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  List<Map<String, String>> chartItemData = [];
  dynamic chartData;
  List<String> convertToList(String inputString) {
    List<String> docList =
        inputString.split(',').map((item) => item.trim()).toList();
    return docList;
  }

  Future<void> getChartData() async {
    chartData = await settingsService.getChartData(widget.data, 5);
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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getChartData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return (chartItemData.isEmpty)
                ? const Center(child: Text("Aucune donnée disponible"))
                : SingleChildScrollView(
                    child: DataTable(
                      columns: _buildColumns(),
                      rows: _buildRows(),
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                    ),
                  );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
        label: Text(widget.data['UnigesBI_fieldx']),
        onSort: (columnIndex, ascending) {
          _sort<String>((item) => item['value_x1'], columnIndex, ascending);
        },
      ),
      DataColumn(
        numeric: true,
        label: Text(widget.data['UnigesBI_fieldy']),
        onSort: (columnIndex, ascending) {
          _sort<String>(
            (item) {
              return item['value_y'];
            },
            columnIndex,
            ascending,
          );
        },
      )
    ];
  }

  void _sort<T>(
    Comparable<T> Function(Map<String, dynamic>) getField,
    int columnIndex,
    bool ascending,
  ) {
    chartItemData.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? aValue.compareTo(bValue as T)
          : bValue.compareTo(aValue as T);
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  List<DataRow> _buildRows() {
    return chartItemData.map((item) {
      String valueX1 = item['value_x1'].toString();
      String valueY = item['value_y'].toString();
      return DataRow(
        cells: [
          DataCell(Text(valueX1)),
          DataCell(Text(valueY)),
        ],
      );
    }).toList();
  }
}
