import 'package:get/get.dart';
import 'package:uniges/services/networkController.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}
