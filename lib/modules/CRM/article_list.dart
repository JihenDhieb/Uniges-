import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/CRM/articleCard.dart';
import 'package:uniges/modules/CRM/crm_service.dart';
import 'package:uniges/modules/CRM/detail_article.dart';
import 'package:uniges/modules/CRM/panier_screen.dart';

class ListArticleScreen extends StatefulWidget {
  final dynamic client;
  const ListArticleScreen({Key? key, required this.client}) : super(key: key);

  @override
  _ListArticleScreenState createState() => _ListArticleScreenState();
}

class _ListArticleScreenState extends State<ListArticleScreen> {
  final CRMService crmService = Get.put(CRMService());

  bool isSearchVisible = false;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async {
    if (!crmService.isInitialized.value) {
      await crmService.initializeService();
    }
  }

  void filterArticles(String query) {
    crmService.filterArticles(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {
              Get.to(() => PanierScreen(client: widget.client));
            },
            child: Icon(Icons.production_quantity_limits_rounded),
          ),
          Positioned(
            right: 0.0,
            top: 0.0,
            child: CircleAvatar(
              radius: 12.0,
              backgroundColor: Colors.red,
              child: Obx(() {
                int itemCount = crmService.cartItems.value.length;
                return Text(
                  itemCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        title: (!isSearchVisible)
            ? Text("Articles")
            : TextField(
                autofocus: isSearchVisible,
                decoration: const InputDecoration(
                  hintText: 'Recherche...',
                  border: UnderlineInputBorder(),
                ),
                onChanged: filterArticles),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (isSearchVisible) {
                    filterArticles("");
                  }
                  isSearchVisible = !isSearchVisible;
                });
              },
              icon: (!isSearchVisible) ? Icon(Icons.search) : Icon(Icons.close))
        ],
      ),
      body: Obx(() {
        if (!crmService.isInitialized.value) {
          return Center(child: CircularProgressIndicator());
        } else if (crmService.filteredArticles.isEmpty) {
          return Center(child: Text("Aucun Article trouvé"));
        } else {
          return _buildListe(crmService.filteredArticles);
        }
      }),
    );
  }

  Widget _buildListe(List<dynamic> menuItems) {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(
        height: 10,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: 120,
            child: _buildListeItem(menuItems[index]));
      },
    );
  }

  Widget _buildListeItem(dynamic itemListe) {
    return GestureDetector(
      onTap: () => onarticleTap(itemListe),
      child: ProductCard(
        artCode: itemListe['Art_Code'],
        artDes: itemListe['Art_Des'],
        artPV: itemListe['Art_PV'] ?? 0.0,
        artFamille2: itemListe['Art_Famille2'] ?? "",
        artStock: itemListe['Art_Stock'],
      ),
    );
  }

  void onarticleTap(itemListe) {
    Get.to(() => DetailArticleScreen(article: itemListe));
  }
}
