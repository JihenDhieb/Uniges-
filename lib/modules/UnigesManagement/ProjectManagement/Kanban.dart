import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniges/modules/UnigesManagement/ProjectManagement/add_tache.dart';
import 'package:uniges/modules/UnigesManagement/TaskManagement/task_detail.dart';
import 'package:uniges/services/UiService.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class KanbanScreen extends StatefulWidget {
  final String? idProject;
  final String? User_idCreate;
  final DateTime? DateEcheance;

  KanbanScreen({this.idProject, this.User_idCreate, this.DateEcheance});

  @override
  _KanbanScreenState createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  late List<dynamic> tasks = [];
  String? selectedProject;
  late List<Map<String, dynamic>> projects = [];
  late List<String> projectIdsList = [];
  late DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    selectedProject = widget.idProject;
    initializeDateFormatting('fr_FR', null);
    _fetchProjects();
    _fetchTasks();
  }

  Future<void> _saveTasksToPreferences(List<dynamic> tasks) async {
    try {
      final List<Map<String, dynamic>> thisWeekTasks = tasks.where((task) {
        DateTime? taskDate = task['DateEcheance'] != null
            ? dateFormat.parse(task['DateEcheance'])
            : null;
        bool isThisWeek =
            taskDate != null && isSameWeek(taskDate, DateTime.now());

        return isThisWeek;
      }).map<Map<String, dynamic>>((task) {
        DateTime taskDate = dateFormat.parse(task['DateEcheance']);
        String dayOfWeek = DateFormat('EEEE', 'fr_FR').format(taskDate);
        print('Mapped task: Title: ${task['Titre']}, Date: $dayOfWeek');
        return {
          'Titre': task['Titre'],
          'DateEcheance': dayOfWeek,
        };
      }).toList();

      if (thisWeekTasks.isEmpty) {
        print('Aucune tâche prévue pour cette semaine');
        return;
      }

      final result = await HomeWidget.saveWidgetData<String>(
        'kanban_tasks',
        json.encode(thisWeekTasks),
      );

      if (result != null && result) {
        print('Sauvegarde des tâches réussie');

        print('Tâches filtrées pour cette semaine:');
        thisWeekTasks.forEach((task) {
          print(
              'Titre: ${task['Titre']}, Date d\'échéance: ${task['DateEcheance']}');
        });
      } else {
        print('Échec de la sauvegarde des tâches');
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde des tâches: $e');
    }
  }

  bool isSameWeek(DateTime date1, DateTime date2) {
    return getWeekOfYear(date1) == getWeekOfYear(date2) &&
        date1.year == date2.year;
  }

  int getWeekOfYear(DateTime date) {
    // Calcul du numéro de semaine de l'année
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int weekOfYear = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (weekOfYear < 1) {
      weekOfYear = getWeekOfYear(DateTime(date.year - 1, 12, 31));
    } else if (weekOfYear > 52) {
      weekOfYear = getWeekOfYear(DateTime(date.year + 1, 1, 1));
    }
    return weekOfYear;
  }

  Future<void> _fetchProjects() async {
    print('Fetching projects...');
    List<dynamic> fetchedProjects =
        await UnigesService.tableRecherche("API_MPProjets");
    List<String> projectIds = [];
    for (var project in fetchedProjects) {
      String projectId = project['idProjet'];
      if (projectId.isNotEmpty) {
        projectIds.add(projectId);
      }
    }

    setState(() {
      projects = fetchedProjects.cast<Map<String, dynamic>>();

      projectIdsList = projectIds;
    });
    print(projects);
  }

  Future<void> _fetchTasks() async {
    tasks = await UnigesService.tableRecherche("API_MPTaches", param: [
      widget.User_idCreate ?? '',
      selectedProject ?? '',
      widget.DateEcheance != null ? widget.DateEcheance!.toString() : ''
    ]);
    await _saveTasksToPreferences(tasks);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kanban'),
        centerTitle: false,
        backgroundColor: Color.fromARGB(255, 236, 234, 234),
      ),
      body: Stack(
        children: [
          Container(
            color: Color.fromARGB(255, 236, 234, 234),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 168, 155, 219),
                      child: Icon(
                        Icons.work,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Tasks',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 90),
                    DropdownButton<String>(
                      value: selectedProject,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedProject = newValue;
                        });
                        _fetchTasks();
                      },
                      style: TextStyle(color: Colors.black),
                      underline: Container(
                        height: 0,
                        color: Colors.transparent,
                      ),
                      elevation: 0,
                      items: [
                        for (var projectId in projectIdsList)
                          DropdownMenuItem<String>(
                            value: projectId,
                            child: Text(projectId),
                          ),
                      ],
                      hint: Text('Select Projet'),
                    ),
                  ],
                ),
                Expanded(
                  child: _buildTaskCarousel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCarousel() {
    Map<String, List<dynamic>> tasksByStatus = _groupTasksByStatus(tasks);

    if (tasksByStatus.isEmpty || tasksByStatus == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return CarouselSlider.builder(
        itemCount: tasksByStatus.length,
        options: CarouselOptions(
          aspectRatio: 16 / 9,
          autoPlay: false,
          enableInfiniteScroll: false,
          height: MediaQuery.of(context).size.height * 0.8,
          viewportFraction: 0.8,
        ),
        itemBuilder: (BuildContext context, int index, _) {
          String status = tasksByStatus.keys.elementAt(index);
          List<dynamic> tasksForStatus = tasksByStatus.values.elementAt(index);
          return _buildTaskCard(status, tasksForStatus);
        },
      );
    }
  }

  Widget _buildTaskCard(String status, List<dynamic> tasksForStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              Text(
                'Statut: ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Color.fromARGB(255, 217, 213, 213),
                  border: Border.all(
                    color: Color.fromARGB(255, 213, 210, 210),
                    width: 2,
                  ),
                ),
                padding: EdgeInsets.all(2),
                child: Text(
                  '$status',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(
                width: 90,
              ),
              IconButton(
                icon: Icon(Icons.more_horiz),
                onPressed: () {},
              ),
            ],
          ),
        ),
        SizedBox(height: 5),
        if (tasksForStatus.isEmpty)
          Center(
            child: Text('Aucune tâche pour ce statut'),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: tasksForStatus.length,
                    itemBuilder: (context, index) {
                      DateTime? dateEcheance =
                          tasksForStatus[index]['DateEcheance'] != null
                              ? DateTime.parse(
                                  tasksForStatus[index]['DateEcheance'])
                              : null;
                      String formattedDate = dateEcheance != null
                          ? DateFormat('yyyy/MM/dd').format(dateEcheance)
                          : 'Date non spécifiée';

                      return Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.6),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      child: Text(
                                        '${tasksForStatus[index]['Titre']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  if (tasksForStatus[index]['DureeEstimee'] !=
                                      null)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red[100],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          Icon(Icons.timer,
                                              size: 20, color: Colors.red),
                                          SizedBox(width: 5),
                                          Text(
                                            ' ${tasksForStatus[index]['DureeEstimee']}',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.redAccent,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  SizedBox(width: 20),
                                  if (formattedDate != null)
                                    Container(
                                      decoration: BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 204, 220, 239),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 20,
                                            color: const Color.fromARGB(
                                                255, 105, 168, 240),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            ' $formattedDate',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Color.fromARGB(
                                                  255, 68, 117, 240),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskDetailScreen(
                                  task: tasksForStatus[index],
                                  projectId: selectedProject,
                                  userIdCreate: widget.User_idCreate,
                                  dateEcheance: widget.DateEcheance,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTaskScreen(
                                onTaskAdded: () {
                                  _KanbanScreenState? kanbanState =
                                      context.findAncestorStateOfType<
                                          _KanbanScreenState>();
                                  if (kanbanState != null) {
                                    kanbanState._saveTasksToPreferences(tasks);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1),
                          ),
                          backgroundColor: Color.fromARGB(255, 239, 231, 231)
                              .withOpacity(0.9),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Ajouter une tâche',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

Map<String, List<dynamic>> _groupTasksByStatus(dynamic project) {
  Map<String, List<dynamic>> tasksByStatus = {};

  if (project is List<dynamic>) {
    for (var task in project) {
      String status = task['Statu'].toString();
      if (!tasksByStatus.containsKey(status)) {
        tasksByStatus[status] = [];
      }
      tasksByStatus[status]!.add(task);
    }
  }

  return tasksByStatus;
}
