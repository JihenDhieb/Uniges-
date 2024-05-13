import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/CRM/crm_service.dart';
import 'package:uniges/modules/CRM/fiche_client.dart';

class listClientScreen extends StatefulWidget {
  @override
  State<listClientScreen> createState() => _listClientScreenState();
}

class _listClientScreenState extends State<listClientScreen> {
  final CRMService crmService = Get.put(CRMService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return (!crmService.isSearchVisible.value)
              ? Text("Clients")
              : TextField(
                  autofocus: crmService.isSearchVisible.value,
                  decoration: const InputDecoration(
                    hintText: 'Recherche...',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: crmService.filterClients);
        }),
        actions: [
          IconButton(
              onPressed: () {
                crmService.toggleSearchVisibility();
                if (!crmService.isSearchVisible.value) {
                  crmService.filterClients("");
                }
                setState(() {});
              },
              icon: (crmService.isSearchVisible.value)
                  ? Icon(Icons.close)
                  : Icon(Icons.search))
        ],
      ),
      body: Column(
        children: [
          buildLastSyncTime(),
          Expanded(
            child: Obx(() {
              if (crmService.filteredClients.isEmpty) {
                return Center(child: CircularProgressIndicator());
              } else {
                return RefreshIndicator(
                    onRefresh: () async {
                      await crmService.syncDataFromServer();
                      setState(() {});
                    },
                    child: _buildList(crmService.filteredClients));
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> clients) {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(
        height: 10,
      ),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: 100,
            child: _buildListItem(clients[index]));
      },
    );
  }

  Widget _buildListItem(dynamic client) {
    final Tiers_RS = client['Tiers_RS'] ?? "--";
    return GestureDetector(
      onTap: () => onClientTap(client),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              color: Colors.grey.shade300,
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 0.0),
              title: Text(
                client['Tiers_code'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              leading: Icon(Icons.person),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
              subtitle: Text(
                Tiers_RS,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            )),
      ),
    );
  }

  void onClientTap(dynamic client) {
    crmService.navigateToClientDetail(client);
  }

  Widget buildLastSyncTime() {
    String lastSyncText = 'Dernière Sync: ${crmService.getLastSyncDate()}';

    return Visibility(
      visible: crmService.getLastSyncDate() != null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          lastSyncText,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
