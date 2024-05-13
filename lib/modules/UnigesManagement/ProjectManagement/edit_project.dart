import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uniges/services/uniges_service.dart';

class EditProjectScreen extends StatefulWidget {
  final String titre;
  final String description;
  final String tiers;
  final String statut;
  final String dateEcheance;
  final String payant;

  EditProjectScreen({
    required this.titre,
    required this.description,
    required this.tiers,
    required this.statut,
    required this.dateEcheance,
    required this.payant,
  });

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _tiersController;
  late TextEditingController _statutController;
  late TextEditingController _dateEcheanceController;
  late TextEditingController _payantController;

  void _save() async {
    final String titre = _titreController.text;
    final String description = _descriptionController.text;
    final String tiers = _tiersController.text;
    final String statut = _statutController.text;
    final String dateEcheance = _dateEcheanceController.text;
    final String payant = _payantController.text;
    Map<String, dynamic> dsMPProject = await UnigesService.dsGet("MPProjet");
    List<dynamic>? projects = dsMPProject["MPProjet"];
    final projectId = dsMPProject["MPProjet"][0]["idProjet"];
    final int? projectIndex =
        projects?.indexWhere((project) => project["idProjet"] == projectId);
    if (projectIndex != null && projectIndex != -1) {
      projects![projectIndex]["Titre"] = titre;
      projects[projectIndex]["Description"] = description;
      projects[projectIndex]["Tiers"] = tiers;
      projects[projectIndex]["Statu"] = statut;
      projects[projectIndex]["DateEcheance"] = dateEcheance;
      projects[projectIndex]["Payant"] = payant;

      if (await UnigesService.dsPost(dsMPProject)) {
        print("Projet modifié avec succès !");
        Navigator.pop(context, {
          'titre': titre,
          'description': description,
          'tiers': tiers,
          'statut': statut,
          'dateEcheance': dateEcheance,
          'payant': payant,
        });
      } else {
        print("Erreur lors de la modification du projet.");
      }
    } else {
      print("Projet non trouvé !");
    }
  }

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.titre);
    _descriptionController = TextEditingController(text: widget.description);
    _tiersController = TextEditingController(text: widget.tiers);
    _statutController = TextEditingController(text: widget.statut);
    _dateEcheanceController = TextEditingController(text: widget.dateEcheance);
    _payantController = TextEditingController(text: widget.payant);
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _tiersController.dispose();
    _statutController.dispose();
    _dateEcheanceController.dispose();
    _payantController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le Projet'),
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
                  String dateEcheanceWithTime = '$pickedDateFormatted 00:00:00';
                  setState(() {
                    _dateEcheanceController.text = dateEcheanceWithTime;
                  });
                }
              },
            ),
            TextFormField(
              controller: _statutController,
              decoration: InputDecoration(labelText: 'Statut'),
            ),
            TextFormField(
              controller: _payantController,
              decoration: InputDecoration(labelText: 'Payant'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _save();
                Navigator.pop(context);
              },
              child: Text('Enregistrer les Modifications'),
            ),
          ],
        ),
      )),
    );
  }
}
