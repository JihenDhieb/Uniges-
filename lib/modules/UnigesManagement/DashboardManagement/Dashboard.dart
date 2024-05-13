import 'package:flutter/material.dart';
import 'package:uniges/services/uniges_service.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late List<dynamic> _rapports = [];
  late List<dynamic> _filteredRapports = [];
  String _selectedCategory = 'Projet';

  @override
  void initState() {
    super.initState();
    _fetchRapports();
  }

  Future<void> _fetchRapports() async {
    _rapports = await UnigesService.tableRecherche("API_ListeRapports");
    _filteredRapports = _rapports;
    setState(() {});
  }

  void _filterRapports(String query) {
    setState(() {
      _filteredRapports = _rapports
          .where((rapport) => rapport['Titre_Tache']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: _filterRapports,
                  decoration: InputDecoration(
                    labelText: 'Rechercher une tâche',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Row(
                children: [
                  _buildCategoryButton('Projet', Icons.work),
                  SizedBox(width: 35),
                  _buildCategoryButton('Tâche', Icons.task),
                  SizedBox(width: 35),
                  _buildCategoryButton('Développeur', Icons.person),
                  SizedBox(width: 35),
                  _buildCategoryButton('Jour', Icons.calendar_today),
                ],
              ),
              SizedBox(
                height: 320,
                child: _buildTachesPar(_selectedCategory),
              ),
            ],
          ),
        ));
  }

  Widget _buildCategoryButton(String category, IconData icon, {Color? color}) {
    bool isSelected = _selectedCategory == category;
    Color iconColor =
        isSelected ? Color.fromARGB(255, 133, 92, 145) : Colors.black;
    return IconButton(
      onPressed: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      icon: Icon(icon, color: color ?? iconColor),
    );
  }

  Widget _buildTachesPar(String category) {
    Map<String, List<dynamic>> tachesParItem = {};
    for (var rapport in _filteredRapports) {
      String item = rapport[_getCategoryField(category)].toString();
      if (!tachesParItem.containsKey(item)) {
        tachesParItem[item] = [];
      }
      tachesParItem[item]!.add(rapport);
    }

    return ListView.builder(
      itemCount: tachesParItem.length,
      itemBuilder: (context, index) {
        String key = tachesParItem.keys.elementAt(index);
        List<dynamic> listeTaches = tachesParItem[key]!;
        return ExpansionTile(
          title: Text(key),
          children: listeTaches.map((rapport) {
            return Card(
              margin: EdgeInsets.all(8),
              elevation: 5,
              child: ListTile(
                title: Text(rapport['Titre_Tache'].toString()),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _getCategoryField(String category) {
    switch (category) {
      case 'Projet':
        return 'idProjet';
      case 'Tâche':
        return 'id_tache';
      case 'Développeur':
        return 'IdUserCreate';
      case 'Jour':
        return 'Date_realisation';
      default:
        return 'idProjet';
    }
  }
}
