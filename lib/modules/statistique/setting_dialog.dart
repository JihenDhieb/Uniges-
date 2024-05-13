import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'statistique_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final StatistiqueService settingsService = Get.find();

  DateTime debut = DateTime.now();
  DateTime fin = DateTime.now();

  bool showBankCheckboxes = false;
  bool showCompanyCheckboxes = false;

  TextEditingController DateFin = TextEditingController();
  TextEditingController DateDebut = TextEditingController();

  DateTime dateD = DateTime.now();
  DateTime dateF = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBankSection(),
            const SizedBox(height: 16),
            _buildCompanySection(),
            const SizedBox(height: 16),
            _buildDateRangePicker(context),
            const SizedBox(
              height: 16,
            ),
            ToggleSwitch(
              minWidth: 90.0,
              initialLabelIndex: (settingsService.isCompanyBanksOrder) ? 0 : 1,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              labels: const ['Societe/\nBanque', 'Banque/\nSociete'],
              // icons: [Icons, FontAwesomeIcons.venus],
              activeBgColors: const [
                [Colors.blue],
                [Colors.pink]
              ],
              onToggle: (index) {
                (index == 0)
                    ? settingsService.isCompanyBanksOrder = true
                    : settingsService.isCompanyBanksOrder = false;
                settingsService.getFilteredData();
                settingsService.update();
              },
            ),
            const SizedBox(
              height: 16,
            ),
            ToggleSwitch(
              minWidth: 90.0,
              initialLabelIndex: (settingsService.isPerMonth) ? 1 : 0,
              cornerRadius: 20.0,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey,
              inactiveFgColor: Colors.white,
              totalSwitches: 2,
              labels: const ['Par jour', 'Par month'],
              // icons: [Icons, FontAwesomeIcons.venus],
              activeBgColors: const [
                [Colors.blue],
                [Colors.pink]
              ],
              onToggle: (index) {
                (index == 0)
                    ? settingsService.isPerMonth = false
                    : settingsService.isPerMonth = true;
                settingsService.selectedDate.value = DateTime.now();
                settingsService.getFilteredData();
                settingsService.update();
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildBankSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showBankCheckboxes = !showBankCheckboxes;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select banks:'),
                  Icon(
                    showBankCheckboxes
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (showBankCheckboxes)
            Column(
              children: [
                GetBuilder<StatistiqueService>(
                  builder: (controller) {
                    return Column(
                      children: controller.banks.map<Widget>((bank) {
                        bool isSelected =
                            controller.selectedBanks.contains(bank['code']);

                        return CheckboxListTile(
                          title: Text(bank['Nom']),
                          value: isSelected,
                          onChanged: (newValue) {
                            if (isSelected) {
                              controller.selectedBanks.remove(bank['code']);
                            } else {
                              controller.selectedBanks.add(bank['code']);
                            }
                            settingsService.getFilteredData();
                            controller.update();
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildCompanySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showCompanyCheckboxes = !showCompanyCheckboxes;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select companies:'),
                  Icon(
                    showCompanyCheckboxes
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (showCompanyCheckboxes)
            Column(
              children: [
                GetBuilder<StatistiqueService>(
                  builder: (controller) {
                    return Column(
                      children: controller.companies.map<Widget>((company) {
                        bool isSelected = controller.selectedCompanies
                            .contains(company['code']);

                        return CheckboxListTile(
                          title: Text(company['Nom']),
                          value: isSelected,
                          onChanged: (newValue) {
                            if (isSelected) {
                              controller.selectedCompanies
                                  .remove(company['code']);
                            } else {
                              controller.selectedCompanies.add(company['code']);
                            }
                            settingsService.getFilteredData();
                            controller.update();
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: TextFormField(
            controller: DateDebut,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today), labelText: "Date début"),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: dateD,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              String formattedDate =
                  DateFormat('yyyy-MM-dd').format(pickedDate!);

              settingsService.setStartDate(pickedDate);
              DateDebut.text = formattedDate;
            },
          ),
        ),
        const SizedBox(width: 40),
        SizedBox(
          width: 145,
          child: TextFormField(
            controller: DateFin,
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today), labelText: "Date fin"),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: dateF,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100));
              String formattedDate =
                  DateFormat('yyyy-MM-dd').format(pickedDate!);

              settingsService.setEndDate(pickedDate);
              DateFin.text = formattedDate;
            },
          ),
        ),
      ],
    );
  }
}
