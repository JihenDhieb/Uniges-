import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uniges/modules/Dashboard/Screens/bar_chart_two_axis.dart';
import 'package:uniges/modules/Dashboard/Screens/chart_setting.dart';
import 'package:uniges/modules/Dashboard/Screens/line_chart.dart';

import 'package:uniges/modules/Dashboard/Screens/pie_chart.dart';
import 'package:uniges/modules/Dashboard/Screens/stacked_bar_chart.dart';
import 'package:uniges/modules/Dashboard/Screens/table_chart.dart';
import 'package:uniges/modules/Dashboard/Screens/table_chart_twoX.dart';
import 'package:uniges/modules/Dashboard/services/dashboard_service.dart';
import 'package:uniges/widgets/drawing_board.dart';

import 'bar_chart.dart';

class ChartDetails extends StatefulWidget {
  final dynamic data;

  const ChartDetails({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ChartDetailState createState() => _ChartDetailState();
}

class _ChartDetailState extends State<ChartDetails> {
  final DashboarsService dashboardService = Get.find();
  dynamic chartData;
  List<String> filterList = [];
  List<dynamic> fieldsList = [];
  String selectedTableRdDes = "";
  String selectedOperationY = "";
  List<String> xlist = [];
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void extractValues(String combinedString) {
    if (combinedString == "count(*)") {
      setState(() {
        selectedOperationY = "none";
        selectedTableRdDes = "count(*)";
        fieldsList.add({
          'TableRD_Champs': combinedString,
          'TableRD_Des': "nombre occurrence",
        });
      });
      return;
    }
    combinedString = combinedString.trim();

    String cleanedInput = combinedString
        .replaceAll(' ', '')
        .replaceAll('(', ',')
        .replaceAll(')', '');
    List<String> splitStrings = cleanedInput.split(',');

    if (splitStrings.length == 2) {
      setState(() {
        selectedOperationY = splitStrings[0].trim().toLowerCase();
        selectedTableRdDes = splitStrings[1].trim();
      });

      bool isYFieldExists = fieldsList
          .any((field) => field['TableRD_Champs'] == selectedTableRdDes);
      if (!isYFieldExists) {
        setState(() {
          fieldsList.add({
            'TableRD_Champs': selectedTableRdDes,
            'TableRD_Des': selectedTableRdDes,
          });
        });
      }
    }
  }

  DropdownButton<String> buildDropdownButtonOperation() {
    return DropdownButton<String>(
      value: selectedOperationY,
      items: dashboardService.listeOperations.map((item) {
        return DropdownMenuItem<String>(
          value: item['operation_code'].toString(),
          child: Text(item['operation_name'].toString()),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedOperationY = newValue!;
          if (newValue == "none") {
            chartData["UnigesBI_fieldy"] = selectedTableRdDes;
          } else {
            chartData["UnigesBI_fieldy"] =
                "$selectedOperationY($selectedTableRdDes)";
          }
        });
      },
    );
  }

  void initializeData() {
    chartData = widget.data;
    xlist = chartData["UnigesBI_fieldx"].split(",");
    fetchFieldListe();

    if (chartData["UnigesBI_filter"].toString() != "null" &&
        chartData["UnigesBI_filter"].toString() != "") {
      filterList =
          chartData["UnigesBI_filter"].toString().toLowerCase().split('and');
    }
  }

  Future<void> fetchFieldListe() async {
    bool isXFieldExists = true;
    bool isX1FieldExists = true;
    bool isX2FieldExists = true;
    fieldsList =
        await dashboardService.getFields(chartData["UnigesBI_Dataset"]);
    if (xlist.length > 1) {
      isX1FieldExists =
          fieldsList.any((field) => field['TableRD_Champs'] == xlist[0]);
      isX2FieldExists =
          fieldsList.any((field) => field['TableRD_Champs'] == xlist[1]);
    } else {
      isXFieldExists = fieldsList.any(
          (field) => field['TableRD_Champs'] == chartData["UnigesBI_fieldx"]);
    }

    // If it doesn't exist, add it to fieldsList
    if (!isXFieldExists) {
      fieldsList.add({
        'TableRD_Champs': chartData["UnigesBI_fieldx"],
        'TableRD_Des': chartData["UnigesBI_fieldx"],
      });
    }
    if (!isX1FieldExists) {
      fieldsList.add({
        'TableRD_Champs': xlist[0],
        'TableRD_Des': xlist[0],
      });
    }
    if (!isX2FieldExists) {
      fieldsList.add({
        'TableRD_Champs': xlist[1],
        'TableRD_Des': xlist[1],
      });
    }
    extractValues(chartData['UnigesBI_fieldy']);
    setState(() {});
  }

  void removeFiltre(String filtreName) {
    setState(() {
      filterList.remove(filtreName);
      chartData['UnigesBI_filter'] = filterList.join(' and ');
    });
  }

  void onCaptureScreenTap() async {
    final image = await screenshotController.capture();

    if (image == null) return;
    Get.to(() => DrawingBoard(backgroundImage: image));
  }

  void onAddFiltreIconPress() {
    TextEditingController valueFiltreController = TextEditingController();
    var xfield = fieldsList.first['TableRD_Champs'];
    var operation = dashboardService.operationsList.first;
    Get.dialog(
      AlertDialog(
        title: const Text("Ajouter Filter"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16.0),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: xfield,
                    items: fieldsList.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['TableRD_Champs'],
                        child: Text(item['TableRD_Des']),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(
                        () {
                          xfield = newValue.toString();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  DropdownButton<String>(
                    value: operation,
                    hint: const Text('Select an operation'),
                    onChanged: (String? newValue) {
                      setState(
                        () {
                          operation = newValue.toString();
                        },
                      );
                    },
                    items: dashboardService.operationsList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: valueFiltreController,
                            onChanged: (value) {},
                            decoration:
                                const InputDecoration(hintText: "Value"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              var filterStatement =
                  "$xfield$operation'${valueFiltreController.text}'";
              addFilter(filterStatement);

              Get.back();
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void addFilter(String statement) {
    setState(() {
      filterList.add(statement);
      if (chartData['UnigesBI_filter'] == null ||
          chartData['UnigesBI_filter'] == "") {
        chartData['UnigesBI_filter'] = statement;
      } else {
        chartData['UnigesBI_filter'] += " and $statement";
      }
    });
  }

  DropdownButton<String> buildDropdownButtonX() {
    return DropdownButton<String>(
      value: chartData["UnigesBI_fieldx"].toString(),
      items: fieldsList.map((item) {
        return DropdownMenuItem<String>(
          value: item['TableRD_Champs'].toString(),
          child: Text(item['TableRD_Des'].toString()),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          chartData["UnigesBI_fieldx"] = newValue.toString();
        });
      },
    );
  }

  DropdownButton<String> buildDropdownButtonX1() {
    return DropdownButton<String>(
      value: xlist[0],
      items: fieldsList.map((item) {
        return DropdownMenuItem<String>(
          value: item['TableRD_Champs'],
          child: Text(item['TableRD_Des']),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          xlist[0] = newValue.toString();
        });
      },
    );
  }

  DropdownButton<String> buildDropdownButtonX2() {
    return DropdownButton<String>(
      value: xlist[1],
      items: fieldsList.map((item) {
        return DropdownMenuItem<String>(
          value: item['TableRD_Champs'],
          child: Text(item['TableRD_Des']),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          xlist[1] = newValue.toString();
        });
      },
    );
  }

  Widget _buildChart() {
    switch (chartData["UnigesBI_ChartType"].toString().toUpperCase()) {
      case 'BARCHART':
        if ((chartData['UnigesBI_fieldx'].toString().contains(','))) {
          return BarflChartTwoAxes(
            data: chartData,
          );
        } else {
          return MyBarChartWidget(
            data: chartData,
            isVertical: false,
            isDetail: true,
            key: Key(chartData['id'].toString()),
          );
        }
      case 'BARCHARTV':
        return MyBarChartWidget(
          data: chartData,
          isVertical: true,
          isDetail: true,
          key: Key(chartData['id'].toString()),
        );
      case 'PIECHART':
        return MyPieChartWidget(
          data: chartData,
          key: Key(chartData['id'].toString()),
        );
      case 'LINECHART':
        return MyLineChartWidget(
          data: chartData,
          key: Key(chartData['id'].toString()),
        );
      case 'STACKEDBARCHART':
        return StackedBarChart(
          data: chartData,
          key: Key(chartData['id'].toString()),
        );
      case 'TABLECHART':
        return TableChart(
          data: chartData,
          key: Key(chartData['id'].toString()),
        );
      case 'TABLE_MULTI':
        return tableChartDoubleX(
          data: chartData,
          key: Key(chartData['id'].toString()),
        );
      default:
        return Container();
    }
  }

  Widget _buildTypeIconsButton(String chartType, IconData icon) {
    return IconButton.outlined(
      onPressed: () {
        setState(() {
          chartData["UnigesBI_ChartType"] = chartType;
        });
      },
      icon: Icon(icon),
      color:
          chartData["UnigesBI_ChartType"].toString().toUpperCase() == chartType
              ? const Color.fromARGB(255, 37, 33, 243)
              : Colors.grey,
    );
  }

  DropdownButton<String> buildDropdownButtonY() {
    return DropdownButton<String>(
      isExpanded: false,
      value: selectedTableRdDes,
      items: fieldsList.map((item) {
        return DropdownMenuItem<String>(
          value: item['TableRD_Champs'],
          child: Text(item['TableRD_Des']),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedTableRdDes = newValue!;
          if (selectedOperationY == "none") {
            chartData['UnigesBI_fieldy'] = newValue;
          } else {
            chartData['UnigesBI_fieldy'] =
                "$selectedOperationY($selectedTableRdDes)";
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var boxDecoration = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    );
    return Scaffold(
      appBar: AppBar(
        title: Expanded(
          child: Text(
            chartData['UnigesBI_Titre'] ?? "chart details",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 2,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                    showDragHandle: true,
                    context: context,
                    builder: (BuildContext context) {
                      return SettingsChartScreen();
                    });
              },
              icon: const Icon(Icons.edit))
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: boxDecoration,
              child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: (xlist.length > 1)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTypeIconsButton(
                                "STACKEDBARCHART", Icons.stacked_bar_chart),
                            _buildTypeIconsButton("BARCHART", Icons.bar_chart),
                            _buildTypeIconsButton(
                                "TABLE_MULTI", Icons.table_chart_rounded),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTypeIconsButton("PIECHART", Icons.pie_chart),
                            RotatedBox(
                                child: _buildTypeIconsButton(
                                    "BARCHART", Icons.bar_chart),
                                quarterTurns: 45),
                            _buildTypeIconsButton(
                                "BARCHARTV", Icons.bar_chart_outlined),
                            _buildTypeIconsButton(
                                "LINECHART", Icons.show_chart),
                            _buildTypeIconsButton(
                                "TABLECHART", Icons.table_chart_rounded),
                          ],
                        )),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: boxDecoration,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                        onPressed: onAddFiltreIconPress,
                        icon: const Icon(Icons.add),
                        label: const Text("Filter")),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: filterList.map((filtre) {
                          return Chip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 98, 82, 243),
                            labelPadding: const EdgeInsets.all(8.0),
                            label: Text(
                              filtre,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            deleteIconColor: Colors.white,
                            deleteIcon: const Icon(
                              Icons.remove_circle,
                            ),
                            onDeleted: () {
                              removeFiltre(filtre);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.maxFinite,
              decoration: boxDecoration,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Axe des X :",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          if (xlist.length == 1) buildDropdownButtonX(),
                          if (xlist.length > 1) buildDropdownButtonX1(),
                          if (xlist.length > 1) buildDropdownButtonX2()
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            "Axe des Y :",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          buildDropdownButtonY(),
                          const SizedBox(
                            width: 5,
                          ),
                          buildDropdownButtonOperation(),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Screenshot(
              controller: screenshotController,
              child: Container(
                width: double.maxFinite,
                height: 350,
                decoration: boxDecoration,
                child: Column(
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildChart(),
                    )),
                  ],
                ),
              ),
            )
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          onCaptureScreenTap();
        },
        child: const Icon(Icons.screen_share),
      ),
    );
  }
}
