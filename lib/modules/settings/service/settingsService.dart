import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

var defaultListSetting = [
  {
    "name": "GENERAL",
    "children": [
      {
        "name": "QRCode",
        "children": [
          {"name": "cryptage", "value": "false"},
        ],
      },
      {
        "name": "Code a Barre",
        "children": [
          {"name": "separator", "value": "%"},
          {"name": "Variable_Order", "value": "Code_art,Sto_Lot"},
        ],
      },
    ],
  },
  {
    "name": "WMS",
    "children": [
      {
        "name": "Réception",
        "children": [
          {"name": "Site_Code", "value": "SFX"},
          {"name": "OFSParam_Code", "value": "SOF"},
        ],
      },
      {
        "name": "Colisage",
        "children": [
          {"name": "Art_Code", "value": ""},
          {"name": "OF_Num", "value": ""},
          {"name": "Art_Unite", "value": ""},
        ],
      },
    ],
  },
  {
    "name": "DASHBOARD",
    "children": [
      {
        "name": "GENERAL",
        "children": [
          {"name": "Chart_Color", "value": "red"},
        ],
      },
    ],
  },
];

class SettingsController extends GetxController {
  final box = GetStorage();
  RxList<Map<String, dynamic>> settingsList = <Map<String, dynamic>>[].obs;
  RxBool hasChanges = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettingsList();
  }

  void loadSettingsList() {
    final storedList = box.read<List<dynamic>>('settingList');
    if (storedList != null) {
      settingsList.value = List.from(storedList);
    } else {
      box.write('settingList', defaultListSetting);
      loadSettingsList();
    }
  }

  void updateSettingValue(String champName, dynamic newValue) {
    _updateSettingValueRecursive(settingsList, champName, newValue);
    hasChanges.value = true;
  }

  void _updateSettingValueRecursive(
      List<dynamic> settings, String champName, dynamic newValue) {
    for (final item in settings) {
      if (item['children'] != null) {
        _updateSettingValueRecursive(item['children'], champName, newValue);
      }
      if (item.containsKey('name') && item['name'] == champName) {
        item['value'] = newValue;
        return;
      }
    }
  }

  dynamic getValueByChampName(String champName) {
    return _getValueByChampNameRecursive(settingsList, champName);
  }

  Map<String, String> extractVariablesFromCodeBarre(
      String inputString, String separator, List<String> variableList) {
    List<String> stringList = inputString.split(separator);
    Map<String, String> variableMap = {};

    for (int i = 0; i < variableList.length; i++) {
      if (i < stringList.length) {
        variableMap[variableList[i]] = stringList[i];
      } else {
        variableMap[variableList[i]] = '';
      }
    }

    return variableMap;
  }

  dynamic _getValueByChampNameRecursive(
      List<dynamic> settings, String champName) {
    for (final item in settings) {
      if (item['children'] != null) {
        final value =
            _getValueByChampNameRecursive(item['children'], champName);
        if (value != null) {
          return value;
        }
      }
      if (item.containsKey('name') && item['name'] == champName) {
        return item['value'];
      }
    }
    return null;
  }

  void saveChanges() {
    box.write('settingList', settingsList.toList());
    hasChanges.value = false;
    Get.snackbar('Success', 'Changes saved successfully');
  }
}
