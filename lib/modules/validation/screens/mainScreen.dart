import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/modules/validation/screens/docDetails.dart';

class MainScreenValidation extends StatefulWidget {
  const MainScreenValidation({Key? key}) : super(key: key);

  @override
  State<MainScreenValidation> createState() => _MainScreenValidationState();
}

class _MainScreenValidationState extends State<MainScreenValidation> {
  dynamic data = [];
  dynamic filteredData;
  bool isSearchVisible = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDoc();
  }

  void _filterDocs(String query) {
    if (query == "") {
      filteredData = data;
      return;
    }
    setState(() {
      filteredData = data.where((doc) {
        String docRS = doc["Doc_RS"].toString().toLowerCase();
        String docTHT = doc["Doc_THT"].toString().toLowerCase();
        String docNum = doc["Doc_Num"].toString().toLowerCase();
        String docDate = DateFormat("dd/MM/yyyy")
            .format(DateTime.parse(doc["Doc_Date"]))
            .toLowerCase();

        return docRS.contains(query.toLowerCase()) ||
            docTHT.contains(query.toLowerCase()) ||
            docNum.contains(query.toLowerCase()) ||
            docDate.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: (!isSearchVisible)
              ? const Text("Liste de documents")
              : TextField(
                  autofocus: isSearchVisible,
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Recherche...',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: _filterDocs),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isSearchVisible = !isSearchVisible;
                    if (isSearchVisible) {
                      _searchController.text = "";
                      _filterDocs("");
                    }
                  });
                },
                icon: const Icon(Icons.search))
          ]),
      body: Column(
        children: [
          Expanded(
            child: _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (filteredData == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (filteredData.isEmpty) {
      return const Center(child: Text("Aucune donnée disponible"));
    } else {
      return ListView.builder(
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          var obj = filteredData[index];
          return _buildListItem(obj);
        },
      );
    }
  }

  Widget _buildListItem(dynamic obj) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () async => await onCardTap(obj),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${obj["Doc_Num"]}",
                          style: const TextStyle(fontSize: 18)),
                      Text(
                        DateFormat("dd/MM/yyyy")
                            .format(DateTime.parse(obj["Doc_Date"])),
                        style: const TextStyle(
                            fontSize: 16, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "${obj["Doc_RS"]}",
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("${obj["Doc_THT"]}",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text("${obj["Devise_Code"]}",
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onCardTap(dynamic object) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocDetails(object["Doc_Num"], object["Doc_Type"], callback: getDoc),
      ),
    );
  }

  Future<void> getDoc() async {
    try {
      data = await UnigesService.tableRecherche("API_AppValidation_ListDoc");
      setState(() {
        filteredData = data;
      });
    } catch (error) {
      print("Error fetching data: $error");
    }
  }
}
