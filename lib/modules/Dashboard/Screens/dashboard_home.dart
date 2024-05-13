import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/Dashboard/Screens/bar_chart.dart';
import 'package:uniges/modules/Dashboard/Screens/bar_chart_two_axis.dart';
import 'package:uniges/modules/Dashboard/Screens/chart_details.dart';
import 'package:uniges/modules/Dashboard/Screens/line_chart.dart';
import 'package:uniges/modules/Dashboard/Screens/pie_chart.dart';
import 'package:uniges/modules/Dashboard/Screens/stacked_bar_chart.dart';
import 'package:uniges/widgets/customSpinner.dart';

import '../services/dashboard_service.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final DashboarsService dashboardService = Get.put(DashboarsService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: dashboardService.initializeService(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return TabBarprincipal(
            data: dashboardService.dataStruct,
          );
        } else {
          return const Center(child: CustomLogoSpinner());
        }
      },
    ));
    /*  */
  }
}

class TabBarprincipal extends StatelessWidget {
  final Map<dynamic, dynamic> data;

  const TabBarprincipal({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: data.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          bottom: TabBar(
            dividerColor: Colors.transparent,
            tabs: data.keys.map<Widget>((item) {
              return Tab(text: item);
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: data.values.map<Widget>((item) {
            return SecondTabBar(
              data: item,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SecondTabBar extends StatefulWidget {
  final Map<dynamic, dynamic> data;

  const SecondTabBar({super.key, required this.data});

  @override
  State<SecondTabBar> createState() => _SecondTabBarState();
}

class _SecondTabBarState extends State<SecondTabBar>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final DashboarsService dashboarsService = Get.find();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.data.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar.secondary(
          labelColor: Colors.blue,
          controller: _tabController,
          tabs: widget.data.keys.map<Widget>((item) {
            return Tab(text: item);
          }).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.data.values.map<Widget>((item) {
              return ListView.builder(
                itemCount: item.length,
                itemBuilder: (context, index) {
                  final data =
                      dashboarsService.getChartById((item[index]).toString());
                  return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                                offset: Offset(0, 2),
                                color: Colors.grey,
                                spreadRadius: 3,
                                blurRadius: 2)
                          ]),
                      height: 330,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              var dataCopy = json.decode(json.encode(data));
                              Get.to(() => (ChartDetails(
                                    data: dataCopy,
                                    key: UniqueKey(),
                                  )));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    data!['UnigesBI_Titre'].toString(),
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(Icons.fullscreen_sharp)
                                ],
                              ),
                            ),
                          ),
                          _buildChart(data),
                        ],
                      ));
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(dynamic data) {
    switch (data['UnigesBI_ChartType'].toString().toUpperCase()) {
      case 'BARCHART':
        if ((data['UnigesBI_fieldx'].toString().contains(','))) {
          return BarflChartTwoAxes(
            data: data,
          );
        } else {
          return MyBarChartWidget(
            data: data,
            isVertical: false,
            isDetail: false,
            key: Key(data['id'].toString()),
          );
        }

      case 'PIECHART':
        return MyPieChartWidget(
          data: data,
          key: Key(data['id'].toString()),
        );
      case 'LINECHART':
        return MyLineChartWidget(
          data: data,
          key: Key(data['id'].toString()),
        );
      case 'STACKEDBARCHART':
        return StackedBarChart(
          data: data,
          key: Key(data['id'].toString()),
        );
      default:
        return Container();
    }
  }
}
