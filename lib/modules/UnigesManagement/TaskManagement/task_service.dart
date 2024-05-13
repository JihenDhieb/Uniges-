import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uniges/services/uniges_service.dart';

class TaskService extends GetxController {
  final box = GetStorage();
  dynamic tasks = <dynamic>[].obs;
  RxList<dynamic> filteredTasks = <dynamic>[].obs;

  RxBool isSearchVisible = false.obs;

  RxBool isInitialized = false.obs;
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
    tasks = (box.read('tasks') ?? []);
    if (tasks.isEmpty) {
      List<String> params = [',1679385108107', ',,'];
      List<dynamic> tasks =
          await UnigesService.tableRecherche("API_MPTaches", param: params);
      box.write('tasks', tasks);
    }
    filteredTasks.assignAll(tasks);
  }

  Future<void> syncDataFromServer() async {
    try {
      List<String> params = [',1679385108107', ',,'];
      List<dynamic> tasks =
          await UnigesService.tableRecherche("API_MPTaches", param: params);
      box.write('tasks', tasks);
      await setLastSyncDate(DateTime.now());
      filteredTasks.assignAll(tasks);
      update();
    } catch (e) {
      print('Synchronization error: $e');
    }
  }

  void filterByStatus(String status) {
    if (status.isEmpty) {
      filteredTasks.assignAll(tasks);
    } else {
      filteredTasks.assignAll(tasks.where((task) =>
          task['Statu'] != null &&
          task['Statu'].toString().toLowerCase() == status.toLowerCase()));
    }
  }

  void sortByPriority() {
    filteredTasks.sort((a, b) {
      final int priorityA = a['Priorite'] ?? 0;
      final int priorityB = b['Priorite'] ?? 0;
      return priorityA.compareTo(priorityB);
    });
  }

  void toggleSearchVisibility() {
    isSearchVisible.value = !isSearchVisible.value;
    update();
  }
}
