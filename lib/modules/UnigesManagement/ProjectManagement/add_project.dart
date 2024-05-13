import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uniges/services/uniges_service.dart';

class AddProjectScreen extends StatefulWidget {
  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tiersController = TextEditingController();
  final TextEditingController _dateEcheanceController = TextEditingController();
  final TextEditingController _payantController = TextEditingController();
  final TextEditingController _statuController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajout de Projet'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titreController,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextFormField(
                controller: _tiersController,
                decoration: InputDecoration(labelText: 'Tiers'),
              ),
              TextFormField(
                controller: _statuController,
                decoration: InputDecoration(labelText: 'Statut'),
              ),
              TextFormField(
                controller: _dateEcheanceController,
                decoration: InputDecoration(labelText: 'Date d\'échéance'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    String pickedDateFormatted =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    String dateEcheanceWithTime =
                        '$pickedDateFormatted 00:00:00';
                    setState(() {
                      _dateEcheanceController.text = dateEcheanceWithTime;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _payantController,
                decoration: InputDecoration(labelText: 'Payant'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _save();
                },
                child: Text('Ajouter Projet'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    final String titre = _titreController.text;
    final String description = _descriptionController.text;
    final String tiers = _tiersController.text;
    final String dateEcheance = _dateEcheanceController.text;
    final String payant = _payantController.text;
    final String statu = _statuController.text;

    try {
      Map<String, dynamic> dsMPProjet = await UnigesService.dsGet("MPProjet");
      if (dsMPProjet != null && dsMPProjet.containsKey("MPProjet")) {
        List<dynamic> mpProjetList = dsMPProjet["MPProjet"];
        if (mpProjetList.isNotEmpty) {
          Map<String, dynamic> firstProjet = mpProjetList.first;
          firstProjet["Titre"] = titre;
          firstProjet["Description"] = description;
          firstProjet["DateEcheance"] = dateEcheance;
          firstProjet["DateCreation"] = DateTime.now().toIso8601String();
          firstProjet["Tiers"] = tiers;
          firstProjet["Payant"] = payant;
          firstProjet["Statu"] = statu;
          if (await UnigesService.dsPost(dsMPProjet)) {
            print("Projet ajouté avec succès !");
            Navigator.pop(context);
          } else {
            print("Erreur lors de l'ajout du projet.");
          }
        } else {
          print("Aucun projet trouvé dans la liste MPProjet.");
        }
      } else {
        print("Erreur lors de la récupération des données MPProjet.");
      }
    } catch (e) {
      print("Erreur lors de la récupération des données MPProjet: $e");
    }
  }
}
