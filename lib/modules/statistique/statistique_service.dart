import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uniges/services/uniges_service.dart';

class StatistiqueService extends GetxController {
  // isCompanyBanksOrder :  false ( societe/banks/..)
  //                        true  ( banks/societe/..)
  bool isCompanyBanksOrder = true;
  bool isPerMonth = false;
  dynamic banks = [];
  dynamic companies = [];
  dynamic Data = [];
  dynamic filterData = [];
  dynamic rawData = [];
  dynamic selectedBanks = [];
  dynamic selectedCompanies = [];

  bool isInitialized = false;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString _selectedBankCode = RxString('');
  final RxString _selectedCompanyCode = RxString('');
  set selectedBankCode(String value) => _selectedBankCode.value = value;
  String get selectedBankCode => _selectedBankCode.value;

  set selectedCompanyCode(String value) => _selectedCompanyCode.value = value;
  String get selectedCompanyCode => _selectedCompanyCode.value;
  Future<void> initializeService() async {
    await getAllData();
    isInitialized = true;
  }

  RxList<dynamic> groupedData = <dynamic>[].obs;
  //List<GroupedData> groupedData = [];
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  Future<void> getAllData() async {
    banks = await UnigesService.tableRecherche("apiBanque");
    companies = await UnigesService.tableRecherche("apiSoc");
    Data = await UnigesService.tableRecherche("apiEncFin");
    Data ??= [];
    banks ??= [];
    companies ??= [];
    Data.forEach(verifMontant);
    selectedBanks = banks.map((bank) => bank['Nom']).toList();
    selectedCompanies = companies.map((company) => company['code']).toList();
    getFilteredData();
  }

  void getStructuredData() {
    groupedData
        .assignAll(groupData(filterData, selectedCompanies, selectedBanks));
    update();
  }

  void getFilteredData() {
    DateTime today = DateTime.now().subtract(const Duration(days: 1));
    DateTime filterDate = DateTime(selectedDate.value.year,
        selectedDate.value.month, selectedDate.value.day);
    DateTime todayDate = DateTime(today.year, today.month, today.day);

    filterData = Data.where((data) {
      bool isToday = false;
      bool isSelectedBank = selectedBanks.contains(data['banque']);
      bool isSelectedCompany = selectedCompanies.contains(data['soc']);
      if (isPerMonth) {
        bool isSameMonth = (data['dateEch'] != null)
            ? DateTime.parse(data['dateEch'].toString()).year ==
                    filterDate.year &&
                DateTime.parse(data['dateEch'].toString()).month ==
                    filterDate.month
            : false;
        return isSelectedBank && isSelectedCompany && isSameMonth;
      } else {
        if (selectedDate.value.isAtSameMomentAs(todayDate)) {
          isToday = (data['dateEch'] != null)
              ? DateTime.parse(data['dateEch'].toString())
                  .isBefore(filterDate.add(const Duration(days: 1)))
              : false;
        } else {
          isToday = (data['dateEch'] != null)
              ? DateTime.parse(data['dateEch'].toString())
                  .isAtSameMomentAs(filterDate)
              : false;
        }
        return isSelectedBank && isSelectedCompany && isToday;
      }
    }).toList();

    getStructuredData();
  }

  verifMontant(entry) {
    if (entry['montant'] != null) {
      double montant = double.tryParse(entry['montant'].toString()) ?? 0.0;
      if (entry['nature'] == -1) {
        montant = -montant;
      }
      entry['montant'] = montant;
    } else {
      entry['montant'] = 0.0;
    }
  }

  void setStartDate(DateTime date) {
    startDate.value = date;
  }

  void setEndDate(DateTime date) {
    endDate.value = date;
  }

  Map<String, dynamic> calculateSumsForCompanyAndBanks(
    String company,
  ) {
    double totalIncome = 0.0;
    double totalOutgoing = 0.0;

    if (isCompanyBanksOrder) {
      filterData.forEach((entry) {
        if ((entry['soc'] == company)) {
          double montant = entry['montant'];
          if (entry['nature'] == -1) {
            totalOutgoing += montant;
          } else if (entry['nature'] == 1) {
            totalIncome += montant;
          }
        }
      });
    } else {
      filterData.forEach((entry) {
        if ((entry['banque'] == company)) {
          double montant = entry['montant'];
          if (entry['nature'] == -1) {
            totalOutgoing += montant;
          } else if (entry['nature'] == 1) {
            totalIncome += montant;
          }
        }
      });
    }

    double balance = totalIncome + totalOutgoing;

    Map<String, dynamic> companySummary = {
      'soc': company,
      'totalIncome': totalIncome.toStringAsFixed(3),
      'totalOutgoing': totalOutgoing.toStringAsFixed(3),
      'balance': balance.toStringAsFixed(3),
    };

    return companySummary;
  }

  Map<String, dynamic> calculateSums() {
    double totalIncome = 0.0;
    double totalOutgoing = 0.0;

    filterData.forEach((entry) {
      double montant = entry['montant'];
      if (entry['nature'] == -1) {
        totalOutgoing += montant;
      } else if (entry['nature'] == 1) {
        totalIncome += montant;
      }
    });

    double balance = totalIncome + totalOutgoing;

    Map<String, dynamic> companySummary = {
      'totalIncome': totalIncome.toStringAsFixed(3),
      'totalOutgoing': totalOutgoing.toStringAsFixed(3),
      'balance': balance.toStringAsFixed(3),
    };

    return companySummary;
  }

  num calculateSolde(DateTime dateRapp) {
    DateTime tomorrow = dateRapp.add(const Duration(days: 1));

    DateTime filterDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    double totalIncome = 0.0;
    double totalOutgoing = 0.0;
    num balance = 0.0;

    Data.forEach((entry) {
      if (entry['dateEch'] != null) {
        if (isPerMonth) {
          bool isSelectedBank = selectedBanks.contains(entry['banque']);
          bool isSelectedCompany = selectedCompanies.contains(entry['soc']);
          if (DateTime.parse(entry['dateEch'].toString()).year ==
                  filterDate.year &&
              DateTime.parse(entry['dateEch'].toString()).month ==
                  filterDate.month &&
              isSelectedBank &&
              isSelectedCompany) {
            double montant = entry['montant'];
            if (entry['nature'] == -1) {
              totalOutgoing += montant;
            } else if (entry['nature'] == 1) {
              totalIncome += montant;
            }
          }
        } else {
          if (DateTime.parse(entry['dateEch'].toString())
                  .isBefore(filterDate) &&
              selectedCompanies.contains(entry['soc']) &&
              selectedBanks.contains(entry['banque'])) {
            double montant = entry['montant'];
            if (entry['nature'] == -1) {
              totalOutgoing += montant;
            } else if (entry['nature'] == 1) {
              totalIncome += montant;
            }
          }
        }
      }
    });

    balance = totalIncome + totalOutgoing;
    return balance;
  }

  double calculateReport() {
    double balance = 0;
    DateTime all = DateTime.now().subtract(const Duration(days: 1));
    String formattedDate = DateFormat('dd-MM-yyyy').format(all);

    if (DateFormat('dd-MM-yyyy').format(selectedDate.value) == formattedDate) {
      return 0;
    }

    for (var entry in Data) {
      bool isSelectedBank = selectedBanks.contains(entry['banque']);
      bool isSelectedCompany = selectedCompanies.contains(entry['soc']);
      if (entry['dateEch'] != null && isSelectedBank && isSelectedCompany) {
        String transactionDateString = entry['dateEch'];
        DateTime transactionDate = DateTime.parse(transactionDateString);
        double transactionAmount = entry['montant'];

        if (transactionDate.isBefore(selectedDate.value)) {
          balance += transactionAmount;
          if (entry['nature'] == 1) {
          } else {}
        }
      }
    }
    return balance;
  }

  double calculateTotalMontantParBank(int index, int bankIndex) {
    final List<dynamic> entries =
        groupedData[index]['banks'][bankIndex]['entries'];

    double totalMontant = 0.0;

    for (var entry in entries) {
      totalMontant += entry['montant'];
    }

    return totalMontant;
  }

  double calculateTotalMontantParSoc(int index) {
    final List<dynamic> banks = groupedData[index]['banks'];

    double totalMontant = 0.0;

    for (var bank in banks) {
      final List<dynamic> entries = bank['entries'];
      for (var entry in entries) {
        totalMontant += entry['montant'];
      }
    }

    return totalMontant;
  }

  List<dynamic> groupData(List<dynamic> rawData,
      List<dynamic> selectedCompanies, List<dynamic> selectedBanks) {
    List<dynamic> result = [];
    String company;
    String bank;
    for (var entry in rawData) {
      /** choosing bank/societe or societe/bank */
      if (isCompanyBanksOrder) {
        company = entry['soc'];
        bank = entry['banque'];
      } else {
        company = entry['banque'];
        bank = entry['soc'];
      }

      String type = entry['type'];

      var companyGroup = result.firstWhere(
        (group) => group['company'] == company,
        orElse: () {
          var newGroup = {
            'company': company,
            'isExpanded': false,
            'banks': [],
          };
          result.add(newGroup);
          return newGroup;
        },
      );

      var bankGroup = companyGroup['banks'].firstWhere(
        (bankEntry) => bankEntry['bank'] == bank,
        orElse: () {
          var newBankGroup = {
            'bank': bank,
            'isExpanded': false,
            'entries': [],
          };
          companyGroup['banks'].add(newBankGroup);
          return newBankGroup;
        },
      );

      /*  bankGroup['entries'].add({
        'type': type,
        'montant': entry['montant'],
      });*/

      var typeGroup = bankGroup['entries'].firstWhere(
        (typeEntry) => typeEntry['type'] == type,
        orElse: () {
          var newTypeGroup = {
            'type': type,
            'montant': 0,
          };
          bankGroup['entries'].add(newTypeGroup);
          return newTypeGroup;
        },
      );

      // Update the montant for the type
      typeGroup['montant'] += entry['montant'];
    }

    return result;
  }
}
