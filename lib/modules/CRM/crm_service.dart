import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uniges/modules/CRM/fiche_client.dart';
import 'package:uniges/services/uniges_service.dart';

class CRMService extends GetxController {
  final box = GetStorage();
  dynamic clients = <dynamic>[].obs;
  dynamic articles = <dynamic>[].obs;
  RxList<dynamic> filteredClients = <dynamic>[].obs;
  RxList<dynamic> filteredArticles = <dynamic>[].obs;
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
    // Try to get data from local storage
    articles = (box.read('articles') ?? []);
    clients = (box.read('clients') ?? []);

    // If local storage is empty or data is not available, fetch from the server
    if (articles.isEmpty || clients.isEmpty) {
      articles = await UnigesService.tableRecherche("ArticleCRMAndroid");
      clients = await UnigesService.tableRecherche("ClientsCRMAndroid");

      // Save data to local storage
      box.write('articles', articles);
      box.write('clients', clients);
    }
    filteredClients.assignAll(clients);
    filteredArticles.assignAll(articles);
  }

  Future<void> syncDataFromServer() async {
    try {
      // Sync data from the server
      articles = await UnigesService.tableRecherche("ArticleCRMAndroid");
      clients = await UnigesService.tableRecherche("ClientsCRMAndroid");

      box.write('articles', articles);
      box.write('clients', clients);

      await setLastSyncDate(DateTime.now());

      filteredClients.assignAll(clients);
      filteredArticles.assignAll(articles);

      update();
    } catch (e) {
      print('Synchronization error: $e');
    }
  }

  void filterClients(String query) {
    if (query.isEmpty) {
      filteredClients.assignAll(clients);
    } else {
      filteredClients.assignAll(clients.where((client) =>
          client['Tiers_RS']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          client['Tiers_code']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())));
    }
  }

  void filterArticles(String query) {
    if (query.isEmpty) {
      filteredArticles.assignAll(articles);
    } else {
      filteredArticles.assignAll(articles.where((article) =>
          article['Art_Code'].toString().contains(query.toLowerCase()) ||
          article['Art_Des']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())));
    }
  }

  void toggleSearchVisibility() {
    isSearchVisible.value = !isSearchVisible.value;
    update();
  }

  void navigateToClientDetail(dynamic client) {
    Get.to(() => ficheClientScreen(contact: client));
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity >= 0) {
      cartItems[index]["DocD_Q"] = newQuantity;
    }
  }
}
