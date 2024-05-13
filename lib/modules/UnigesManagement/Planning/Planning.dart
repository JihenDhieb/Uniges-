import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:gantt_chart/gantt_chart.dart';

enum PlanningView {
  list,
  calendar,
  ganttChart,
}

class GanttTask {
  final String title;
  final DateTime start;
  final DateTime end;

  GanttTask({
    required this.title,
    required this.start,
    required this.end,
  });

  String getTitle() {
    return title;
  }
}

class PlanningScreen extends StatefulWidget {
  @override
  _PlanningScreenState createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  PlanningView _currentView = PlanningView.list;
  List<dynamic>? _planning;
  late String _fetchError = '';

  @override
  void initState() {
    super.initState();
    _fetchPlanning();
  }

  Future<void> _fetchPlanning() async {
    try {
      _planning = await UnigesService.tableRecherche("API_MPTache_Planning");
    } catch (error) {
      setState(() {
        _fetchError = 'Erreur lors de la récupération des données';
      });
    }
    setState(() {});
  }

  Widget _buildList() {
    return _planning == null || _planning!.isEmpty
        ? Center(
            child: _fetchError.isNotEmpty
                ? Text(_fetchError)
                : CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: _planning!.length,
            itemBuilder: (context, index) {
              final tasks =
                  _planning![index]['Tasks']; // Accédez à la liste des tâches
              return Card(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Nom: ' + (_planning![index]['Perso_Nom'] ?? ''),
                        style: TextStyle(
                          color: Color.fromARGB(255, 137, 74, 124),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      tileColor: Colors.grey[200],
                      leading: Icon(Icons.person),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Leurs tâches sont :',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: tasks.length,
                      itemBuilder: (context, taskIndex) {
                        final task = tasks[taskIndex];
                        return ListTile(
                          title: Text(
                            'Tâche ${taskIndex + 1}: ${task['Titre'] ?? ''}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description: ${task['Description'] ?? ''}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Date de début: ${task['PlanifDateDebut'] ?? ''}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                'Date de fin: ${task['PlanifDateFin'] ?? ''}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          leading: Icon(Icons.assignment),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget _buildCalendar() {
    return _planning == null || _planning!.isEmpty
        ? Center(
            child: _fetchError.isNotEmpty
                ? Text(_fetchError)
                : CircularProgressIndicator(),
          )
        : Container(
            color: Colors.grey[200],
            child: SfCalendar(
              view: CalendarView.month,
              dataSource: _getDataSource(),
              onTap: (CalendarTapDetails details) {
                final selectedDate = details.date!;
                final tasksForSelectedDate = _getTasksForDate(selectedDate);
                _showTasksForSelectedDate(context, tasksForSelectedDate);
              },

              headerStyle: CalendarHeaderStyle(
                textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
                textAlign: TextAlign.center,
                backgroundColor: Colors.grey[300],
              ),
              todayHighlightColor: Color.fromARGB(255, 141, 76, 110),
              selectionDecoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(10.0),
              ),
              cellEndPadding: 5.0, // Espacement à la fin des cellules
            ),
          );
  }

  Widget _buildGanttChart() {
    List<GanttTask> tasks = _getGanttTasks();

    return tasks.isEmpty
        ? Center(
            child: Text('Aucune tâche à afficher'),
          )
        : ListView(
            children: [
              GanttChartView(
                maxDuration: const Duration(days: 30 * 2),
                startDate: _getEarliestStartDate(tasks),
                dayWidth: 30,
                eventHeight: 20,
                stickyAreaWidth: 200,
                showStickyArea: true,
                showDays: true,
                startOfTheWeek: WeekDay.sunday,
                weekEnds: const {WeekDay.friday, WeekDay.saturday},
                isExtraHoliday: (context, day) {
                  return false;
                },
                events: tasks.map((task) {
                  return GanttAbsoluteEvent(
                    startDate: task.start,
                    endDate: task.end,
                    displayName: task.getTitle(),
                  );
                }).toList(),
              ),
            ],
          );
  }

  DateTime _getEarliestStartDate(List<GanttTask> tasks) {
    DateTime? earliestDate;
    for (final task in tasks) {
      if (earliestDate == null || task.start.isBefore(earliestDate)) {
        earliestDate = task.start;
      }
    }
    return earliestDate ?? DateTime.now();
  }

  CalendarDataSource _getDataSource() {
    List<Appointment> appointments = [];
    if (_planning != null) {
      for (var plan in _planning!) {
        List<dynamic>? tasks = plan['Tasks'];
        if (tasks != null && tasks.isNotEmpty) {
          for (var task in tasks) {
            DateTime? startTime = task['PlanifDateDebut'] != null
                ? DateTime.tryParse(task['PlanifDateDebut'])
                : null;
            DateTime? endTime = task['PlanifDateFin'] != null
                ? DateTime.tryParse(task['PlanifDateFin'])
                : null;
            String? subject = task['Titre'];

            if (startTime != null && endTime != null && subject != null) {
              appointments.add(Appointment(
                startTime: startTime,
                endTime: endTime,
                subject: subject,
                color: Colors.blue,
              ));
            }
          }
        }
      }
    }

    return _MyCalendarDataSource(appointments: appointments);
  }

  List<dynamic> _getTasksForDate(DateTime date) {
    List<dynamic> tasksForDate = [];
    if (_planning != null) {
      for (var plan in _planning!) {
        List<dynamic>? tasks = plan['Tasks'];
        if (tasks != null && tasks.isNotEmpty) {
          for (var task in tasks) {
            DateTime? startTime = task['PlanifDateDebut'] != null
                ? DateTime.tryParse(task['PlanifDateDebut'])
                : null;
            if (startTime != null &&
                startTime.year == date.year &&
                startTime.month == date.month &&
                startTime.day == date.day) {
              tasksForDate.add(task);
            }
          }
        }
      }
    }
    return tasksForDate;
  }

  List<GanttTask> _getGanttTasks() {
    List<GanttTask> tasks = [];

    if (_planning != null) {
      for (var plan in _planning!) {
        List<dynamic>? planTasks = plan['Tasks'];
        if (planTasks != null && planTasks.isNotEmpty) {
          for (var task in planTasks) {
            DateTime? startTime = task['PlanifDateDebut'] != null
                ? DateTime.tryParse(task['PlanifDateDebut'])
                : null;
            DateTime? endTime = task['PlanifDateFin'] != null
                ? DateTime.tryParse(task['PlanifDateFin'])
                : null;
            String? title = task['Titre'];

            if (startTime != null && endTime != null && title != null) {
              tasks.add(
                GanttTask(
                  title: title,
                  start: startTime,
                  end: endTime,
                ),
              );
            }
          }
        }
      }
    }

    return tasks;
  }

  void _showTasksForSelectedDate(BuildContext context, List<dynamic> tasks) {
    int taskNumber = 1;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tâches pour la date sélectionnée',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 107, 62, 110),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: tasks.map((task) {
                      DateTime? startDate = task['PlanifDateDebut'] != null
                          ? DateTime.tryParse(task['PlanifDateDebut'])
                          : null;
                      DateTime? endDate = task['PlanifDateFin'] != null
                          ? DateTime.tryParse(task['PlanifDateFin'])
                          : null;

                      String startDateString = startDate != null
                          ? DateFormat('dd/MM/yyyy').format(startDate)
                          : '';
                      String endDateString = endDate != null
                          ? DateFormat('dd/MM/yyyy').format(endDate)
                          : '';

                      String taskTitle = task['Titre'] ?? '';
                      String personName = task['Perso_Nom'] ?? '';

                      String taskNumberString = 'Tâche $taskNumber';
                      taskNumber++;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            taskNumberString,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            taskTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            'Personne responsable: $personName',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Date de début de planification: $startDateString',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Date de fin de planification: $endDateString',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Divider(color: Colors.grey),
                          SizedBox(height: 15.0),
                        ],
                      );
                    }).toList(),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Fermer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (_currentView) {
      case PlanningView.list:
        currentWidget = _buildList();
        break;
      case PlanningView.calendar:
        currentWidget = _buildCalendar();
        break;
      case PlanningView.ganttChart:
        currentWidget = _buildGanttChart();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Planning'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              setState(() {
                _currentView = PlanningView.list;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _currentView = PlanningView.calendar;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              setState(() {
                _currentView = PlanningView.ganttChart;
              });
            },
          ),
        ],
      ),
      body: currentWidget,
    );
  }
}

class _MyCalendarDataSource extends CalendarDataSource {
  final List<Appointment> appointments;

  _MyCalendarDataSource({required this.appointments});

  @override
  DateTime getStartTime(int index) {
    return appointments[index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments[index].subject;
  }
}
