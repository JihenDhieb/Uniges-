import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:uniges/services/uniges_service.dart';

class AddTaskScreen extends StatefulWidget {
  final VoidCallback? onTaskAdded;

  AddTaskScreen({Key? key, this.onTaskAdded}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _statuController;
  late TextEditingController _dateEcheanceController;
  late TextEditingController _dureeEstimeeController;
  late TextEditingController _dateRealisationController;
  late TextEditingController _dureeRealisationController;
  late TextEditingController _prioriteController;
  late TextEditingController _rankController;

  @override
  void initState() {
    super.initState();

    _titreController = TextEditingController();
    _descriptionController = TextEditingController();
    _statuController = TextEditingController();
    _dateEcheanceController = TextEditingController();
    _dureeEstimeeController = TextEditingController();
    _dateRealisationController = TextEditingController();
    _dureeRealisationController = TextEditingController();
    _prioriteController = TextEditingController();
    _rankController = TextEditingController();
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _statuController.dispose();
    _dateEcheanceController.dispose();
    _dureeEstimeeController.dispose();
    _dateRealisationController.dispose();
    _dureeRealisationController.dispose();
    _prioriteController.dispose();
    _rankController.dispose();
    super.dispose();
  }

  static const platform = MethodChannel('com.example.channelName');
  static Future<void> callSaveMethod(Map<String, dynamic> args) async {
    try {
      await platform.invokeMethod('_save1', args);
      print('_save1');
    } catch (e) {
      print('Error calling _save1() method in Dart: $e');
    }
  }

  void _save1(Map<String, dynamic> args) async {
    print("Début de la méthode _save1");
    final String titre = args['titre'];
    final String description = args['description'];
    final int statu = int.parse(args['statu']);
    final String dureeEstimee = args['dureeEstimee'];
    final String dateRealisation = args['dateRealisation'];
    final String dureeRealisation = args['dureeRealisation'];
    final String priorite = args['priorite'];
    final String rank = args['rank'];
    final String dateEcheance = args['dateEcheance'];

    try {
      Map<String, dynamic> dsMPTache = await UnigesService.dsGet("MPTache");
      if (dsMPTache != null && dsMPTache.containsKey("MPTache")) {
        List<dynamic> mptacheList = dsMPTache["MPTache"];
        if (mptacheList.isNotEmpty) {
          Map<String, dynamic> firstTask = mptacheList.first;
          firstTask["Titre"] = titre;
          firstTask["Description"] = description;
          firstTask["DateCreation"] = DateTime.now().toIso8601String();
          firstTask["Statu"] = statu;
          firstTask["DureeEstimee"] = dureeEstimee;
          firstTask["DateRealisation"] = dateRealisation;
          firstTask["DureeRealisation"] = dureeRealisation;
          firstTask["Priorite"] = priorite;
          firstTask["Rank"] = rank;
          firstTask["DateEcheance"] = dateEcheance;
          if (await UnigesService.dsPost(dsMPTache)) {
            print("Tâche modifiée avec succès !");
            print("Date d'échéance enregistrée: $dateEcheance");
            widget.onTaskAdded?.call();
            if (mounted) {
              Navigator.pop(context);
            }
          } else {
            print("Erreur lors de la modification de la tâche.");
          }
        } else {
          print("Aucune tâche trouvée dans la liste MPTache.");
        }
      } else {
        print("Erreur lors de la récupération des données MPTache.");
      }
    } catch (e) {
      print("Erreur lors de la récupération des données MPTache: $e");
    }
  }

  void _save() async {
    print("Début de la méthode _save");
    final String titre = _titreController.text;
    final String description = _descriptionController.text;
    final int statu = int.parse(_statuController.text);
    final String dureeEstimee = _dureeEstimeeController.text;
    final String dateRealisation = _dateRealisationController.text;
    final String dureeRealisation = _dureeRealisationController.text;
    final String priorite = _prioriteController.text;
    final String rank = _rankController.text;
    final String dateEcheance = _dateEcheanceController.text;

    try {
      Map<String, dynamic> dsMPTache = await UnigesService.dsGet("MPTache");
      if (dsMPTache != null && dsMPTache.containsKey("MPTache")) {
        List<dynamic> mptacheList = dsMPTache["MPTache"];
        if (mptacheList.isNotEmpty) {
          Map<String, dynamic> firstTask = mptacheList.first;
          firstTask["Titre"] = titre;
          firstTask["Description"] = description;
          firstTask["DateCreation"] = DateTime.now().toIso8601String();
          ;
          firstTask["Statu"] = statu;
          firstTask["DureeEstimee"] = dureeEstimee;
          firstTask["DateRealisation"] = dateRealisation;
          firstTask["DureeRealisation"] = dureeRealisation;
          firstTask["Priorite"] = priorite;
          firstTask["Rank"] = rank;
          firstTask["DateEcheance"] = dateEcheance;
          if (await UnigesService.dsPost(dsMPTache)) {
            print("Tâche ajoutée avec succès !");
            print("Date d'échéance enregistrée: $dateEcheance");
            widget.onTaskAdded?.call();
            if (mounted) {
              Navigator.pop(context);
            }
          } else {
            print("Erreur lors de l'ajout de la tâche.");
          }
        } else {
          print("Aucune tâche trouvée dans la liste MPTache.");
        }
      } else {
        print("Erreur lors de la récupération des données MPTache.");
      }
    } catch (e) {
      print("Erreur lors de la récupération des données MPTache: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une Tâche'),
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
                controller: _statuController,
                decoration: InputDecoration(labelText: 'Statut'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _dureeEstimeeController,
                decoration:
                    InputDecoration(labelText: 'Durée estimée (en heures)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _dateRealisationController,
                decoration: InputDecoration(labelText: 'Date de réalisation'),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != DateTime.now()) {
                    String day = pickedDate.day.toString().padLeft(2, '0');
                    String month = pickedDate.month.toString().padLeft(2, '0');
                    String year = pickedDate.year.toString();

                    String formattedDate = '$year/$month/$day';

                    setState(() {
                      _dateRealisationController.text = formattedDate;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _dureeRealisationController,
                decoration: InputDecoration(
                    labelText: 'Durée de réalisation (en heures)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _prioriteController,
                decoration: InputDecoration(labelText: 'Priorité'),
              ),
              TextFormField(
                controller: _rankController,
                decoration: InputDecoration(labelText: 'Rang'),
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
                    String day = pickedDate.day.toString().padLeft(2, '0');
                    String month = pickedDate.month.toString().padLeft(2, '0');
                    String year = pickedDate.year.toString();

                    String dateEcheanceFormatted = '$year/$month/$day';

                    setState(() {
                      _dateEcheanceController.text = dateEcheanceFormatted;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text('Ajouter la Tâche'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
