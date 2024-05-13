import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uniges/services/uniges_service.dart';

class ProjectService extends GetxController {
  final box = GetStorage();
  dynamic projects = <dynamic>[].obs;
  RxList<dynamic> filteredProjects = <dynamic>[].obs;

  RxBool isSearchVisible = false.obs;

  RxBool isInitialized = false.obs;
  RxList<dynamic> cartItems = <dynamic>[].obs;
  String lastSyncKey = 'lastSyncDate';

  @override
  void onInit() {
    super.onInit();
    initializeService();
  }

  DateTime? getLastSyncDate() {
    int? timestamp = box.read<int?>(lastSyncKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<void> setLastSyncDate(DateTime date) async {
    int timestamp = date.millisecondsSinceEpoch;
    await box.write(lastSyncKey, timestamp);
  }

  Future<void> initializeService() async {
    await _getAllData();
    isInitialized.value = true;
  }

  Future<void> _getAllData() async {
    projects = (box.read('projects') ?? []);
    if (projects.isEmpty) {
      projects = await UnigesService.tableRecherche("API_MPProjets");
      box.write('projects', projects);
    }
    filteredProjects.assignAll(projects);
  }

  Future<void> syncDataFromServer() async {
    try {
      projects = await UnigesService.tableRecherche("API_MPProjets");
      box.write('projects', projects);
      await setLastSyncDate(DateTime.now());
      filteredProjects.assignAll(projects);
      update();
    } catch (e) {
      print('Synchronization error: $e');
    }
  }

  void filterProjects(String query) {
    filteredProjects.assignAll(projects);
  }

  void toggleSearchVisibility() {
    isSearchVisible.value = !isSearchVisible.value;
    update();
  }
}
