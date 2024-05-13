import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';

dynamic SelectedCompany;

class Company {
  static final box = GetStorage();

  static bool isCompanyRegistered() {
    List<dynamic>? companies = box.read('companies');
    return companies != null && companies.isNotEmpty;
  }

  static List<dynamic>? getRegisteredCompanies() {
    return box.read<List<dynamic>>('companies');
  }

  static void setSelectedCompany(String nameCompany) {
    List<dynamic>? companies = box.read<List<dynamic>>('companies');

    if (companies != null) {
      var company = companies.firstWhere(
        (company) => company['name'] == nameCompany,
        orElse: () => null,
      );

      if (company != null) {
        SelectedCompany = company;
      } else {
        Fluttertoast.showToast(msg: 'Company not found.');
      }
    } else {
      Fluttertoast.showToast(msg: 'Company not found.');
    }
  }

  static bool registerCompany(Map<String, dynamic> newCompany) {
    List<dynamic>? companies = box.read<List<dynamic>>('companies') ?? [];

    bool companyExists =
        companies.any((company) => company['name'] == newCompany['name']);

    if (!companyExists) {
      companies.add(newCompany);
      box.write('companies', companies);
      return true;
    } else {
      print('Company with the same name already exists.');
      return false;
    }
  }
}
