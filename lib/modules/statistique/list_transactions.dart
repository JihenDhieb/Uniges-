import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/statistique/details_transactions.dart';
import 'statistique_service.dart';

class ListTransaction extends StatefulWidget {
  const ListTransaction({Key? key}) : super(key: key);

  @override
  State<ListTransaction> createState() => _ListTransactionState();
}

class _ListTransactionState extends State<ListTransaction> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Details"),
      ),
      body: GetBuilder<StatistiqueService>(
        builder: (settingsService) {
          if (settingsService.groupedData.isEmpty) {
            return const Center(
              child: Text('aucune donnée trouvée'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  "Date: ${DateFormat('yyyy-MM-dd').format(settingsService.selectedDate.value)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: settingsService.groupedData.length,
                    itemBuilder: (context, index) {
                      var companyData = settingsService.groupedData[index];
                      var companyName = companyData['company'];
                      var sumSoc =
                          settingsService.calculateTotalMontantParSoc(index);

                      return Container(
                        color: Colors.white,
                        //elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ExpansionTile(
                          title: ListTile(
                            title: Text(
                              companyName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: settingsService.isCompanyBanksOrder
                                ? const Icon(Icons.business_outlined)
                                : const Icon(Icons.attach_money),
                            trailing: Text(
                              sumSoc.toStringAsFixed(3),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: sumSoc < 0 ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: List.generate(
                                  companyData['banks'].length,
                                  (bankIndex) {
                                    var bankData =
                                        companyData['banks'][bankIndex];
                                    var sum = settingsService
                                        .calculateTotalMontantParBank(
                                            index, bankIndex);

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: ExpansionTile(
                                        title: ListTile(
                                          title: Text(
                                            bankData['bank'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          leading: settingsService
                                                  .isCompanyBanksOrder
                                              ? const Icon(Icons.attach_money)
                                              : const Icon(
                                                  Icons.business_outlined),
                                          trailing: Text(
                                            sum.toStringAsFixed(3),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: sum < 0
                                                  ? Colors.red
                                                  : Colors.green,
                                            ),
                                          ),
                                        ),
                                        children: List.generate(
                                          bankData['entries'].length,
                                          (entryIndex) {
                                            var entry =
                                                bankData['entries'][entryIndex];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              child: ListTile(
                                                onTap: () {
                                                  Get.to(() =>
                                                      transactionDetails(
                                                        DateD: DateFormat(
                                                                'yyyyMMdd')
                                                            .format(
                                                                settingsService
                                                                    .selectedDate
                                                                    .value),
                                                        DateF: DateFormat(
                                                                'yyyyMMdd')
                                                            .format(
                                                                settingsService
                                                                    .selectedDate
                                                                    .value),
                                                        Banque:
                                                            bankData['bank'],
                                                        Societe: companyName,
                                                        Type: entry['type'],
                                                        nature: "",
                                                        key: UniqueKey(),
                                                      ));
                                                },
                                                title: Text(
                                                  entry['type'],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                trailing: Text(
                                                  entry['montant']
                                                      .toStringAsFixed(3),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: entry['montant'] < 0
                                                        ? Colors.red
                                                        : Colors.green,
                                                  ),
                                                ),
                                                leading: entry['montant'] < 0
                                                    ? const Icon(
                                                        Icons
                                                            .keyboard_double_arrow_up_rounded,
                                                        color: Colors.red,
                                                      )
                                                    : const Icon(
                                                        Icons
                                                            .keyboard_double_arrow_down_rounded,
                                                        color: Colors.green,
                                                      ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
