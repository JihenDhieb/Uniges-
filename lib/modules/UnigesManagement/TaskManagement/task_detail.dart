import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uniges/modules/UnigesManagement/TaskManagement/formulaireRapport.dart';
import 'package:uniges/services/uniges_service.dart';

class TaskDetailScreen extends StatefulWidget {
  final dynamic task;
  final String? projectId;
  final String? userIdCreate;

  final DateTime? dateEcheance;

  TaskDetailScreen(
      {required this.task,
      this.userIdCreate,
      this.projectId,
      this.dateEcheance});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Timer? _timer;
  late DateTime _startTime = DateTime.now();
  late String? projectId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    projectId = widget.projectId;
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {});
  }

  void _savestatu(String projectId, String taskId, String newStatus) async {
    try {
      List<dynamic> projectTasks =
          await UnigesService.tableRecherche("API_MPTaches", param: [
        widget.userIdCreate ?? '',
        projectId ?? '',
        widget.dateEcheance != null ? widget.dateEcheance!.toString() : ''
      ]);

      if (projectTasks != null) {
        for (var task in projectTasks) {
          if (task["idTache"] == taskId) {
            task["Statu"] = newStatus;
            break;
          }
        }
        if (await UnigesService.dsPost(projectTasks)) {
          print("Statut de la tâche mis à jour avec succès !");
          Navigator.pop(context);
        } else {
          print("Erreur lors de la mise à jour du statut de la tâche.");
        }
      } else {
        print("Aucune tâche trouvée dans le projet.");
      }
    } catch (e) {
      print("Erreur lors de la mise à jour du statut de la tâche: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.task['Titre'] ?? "--";
    final description = widget.task['Description'] ?? "--";
    final DateCreation = widget.task['DateCreation'] ?? "--";
    final DateEcheance = widget.task['DateEcheance'] ?? "--";
    final DateRealisation = widget.task['DateRealisation'] ?? "--";
    final DureeRealisation = widget.task['DureeRealisation'] ?? "--";
    final Statu = widget.task['Statu'] ?? "--";
    final rank = widget.task['Rank'] ?? "--";
    final priorite = widget.task['Priorite'] ?? "--";
    final dureeEstimation = widget.task['DureeEstimee'] ?? "--";

    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de la tâche"),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                " $title",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                " $description",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.date_range, color: Colors.green, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Date de création : $DateCreation",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.orange, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Durée estimée : $dureeEstimation",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.date_range, color: Colors.red, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Date d'échéance : $DateEcheance",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blueGrey, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Date de réalisation : $DateRealisation",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.deepPurple, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Durée de réalisation : $DureeRealisation",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.info, color: Colors.black, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Statut : $Statu",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Priorité : $priorite",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.trending_up, color: Colors.teal, size: 20),
                  SizedBox(width: 5),
                  Text(
                    "Rank : $rank",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _startTime = DateTime.now();
                      _timer = Timer.periodic(Duration(minutes: 1), (timer) {});

                      setState(() {
                        widget.task["Statu"] = "1";
                      });
                      _savestatu(projectId!, widget.task["idTache"], "1");
                    },
                    child: Text("Démarrer"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _timer?.cancel();
                      setState(() {
                        widget.task["Statu"] = "2";
                      });
                      _savestatu(projectId!, widget.task["idTache"], "2");

                      String elapsedDuration =
                          '${DateTime.now().difference(_startTime).inMinutes}';
                      ;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormulairePage(
                            initialDuration: elapsedDuration,
                          ),
                        ),
                      );
                    },
                    child: Text("Arrêter"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
