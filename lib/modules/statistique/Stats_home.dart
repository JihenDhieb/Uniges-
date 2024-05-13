import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/modules/statistique/list_transactions.dart';
import 'package:uniges/modules/statistique/month_picker_widget.dart';
import 'package:uniges/modules/statistique/setting_dialog.dart';

import 'bank_card_widget.dart';
import 'statistique_service.dart';

class StatsHome extends StatefulWidget {
  const StatsHome({super.key});

  @override
  _StatsHomeState createState() => _StatsHomeState();
}

class _StatsHomeState extends State<StatsHome> {
  final StatistiqueService settingsService = Get.put(StatistiqueService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _openSettingsDialog();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: settingsService.initializeService(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeLine(),
                  const SizedBox(height: 10),
                  Container(child: _buildStatsUI()),
                  _buildGeneralInfo(),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => const ListTransaction());
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text("Plus d'informations"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: loading(),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatsUI() {
    return GetBuilder<StatistiqueService>(
      builder: (settingsService) {
        var nbre = (settingsService.isCompanyBanksOrder)
            ? settingsService.selectedCompanies.length
            : settingsService.selectedBanks.length;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              nbre,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: BankCardWidget(
                    company: (settingsService.isCompanyBanksOrder)
                        ? settingsService.selectedCompanies[index].toUpperCase()
                        : settingsService.selectedBanks[index].toUpperCase()),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeLine() {
    return GetBuilder<StatistiqueService>(
      builder: (settingsService) {
        return (!settingsService.isPerMonth)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 100,
                    child: DatePicker(
                      DateTime.now().subtract(const Duration(days: 1)),
                      initialSelectedDate: settingsService.selectedDate.value,
                      selectionColor: Colors.blueAccent,
                      selectedTextColor: Colors.white,
                      onDateChange: (date) {
                        settingsService.selectedDate.value = date;
                        settingsService.getFilteredData();
                        settingsService.update();
                      },
                    ),
                  ),
                ],
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: MonthPickerWidget(
                    onDateSelected: (date) {
                      settingsService.selectedDate.value = date;
                      settingsService.getFilteredData();
                      settingsService.update();
                    },
                  ),
                ),
              );
      },
    );
  }

  Widget _buildGeneralInfo() {
    return GetBuilder<StatistiqueService>(
      builder: (settingsService) {
        var info = settingsService.calculateSums();
        num rapport = settingsService.calculateReport();

        return Card(
          elevation: 2.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoItem("Report", Colors.black, rapport.toDouble()),
                const Divider(),
                _buildInfoItem(
                    "Encaissement",
                    const Color.fromARGB(255, 40, 167, 69),
                    double.parse(info['totalIncome'])),
                const Divider(),
                _buildInfoItem(
                    "Décaissement",
                    const Color.fromARGB(255, 220, 53, 69),
                    double.parse(info['totalOutgoing'])),
                const Divider(),
                _buildInfoItem(
                    "Total", Colors.black, double.parse(info['balance'])),
                const Divider(),
                _buildInfoItem("Solde", Colors.black,
                    rapport.toDouble() + double.parse(info['balance'])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, Color color, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          UnigesService.formatNumberWithSpaces(value),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SettingsDialog();
      },
    );
  }

  Widget loading() {
    return Shimmer.fromColors(
        baseColor: const Color.fromARGB(125, 189, 189, 189),
        highlightColor: const Color.fromARGB(186, 245, 245, 245),
        enabled: true,
        child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 100,
                  child: DatePicker(
                    DateTime.now().subtract(const Duration(days: 1)),
                    selectionColor: Colors.blueAccent,
                    selectedTextColor: Colors.white,
                    onDateChange: (date) {},
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      2,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 320,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 0, 128, 255),
                                Color.fromARGB(255, 0, 64, 128),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'SOLDE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Report"),
                      Divider(),
                      Text("Encaissement"),
                      Divider(),
                      Text("Décaissement"),
                      Divider(),
                      Text("Total"),
                      Divider(),
                      Text("Solde"),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Plus d'informations"),
                      style: ElevatedButton.styleFrom(
                        // foregroundColor: Colors.white,
                        //backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            )));
  }
}
