import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/UnigesManagement/TaskManagement/task_detail.dart';
import 'package:uniges/modules/UnigesManagement/TaskManagement/task_service.dart';

class ListTaskScreen extends StatefulWidget {
  @override
  State<ListTaskScreen> createState() => _ListTaskScreenState();
}

class _ListTaskScreenState extends State<ListTaskScreen> {
  final TaskService taskService = Get.put(TaskService());

  @override
  Widget build(BuildContext context) {
    taskService.sortByPriority();
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return (!taskService.isSearchVisible.value)
              ? Text("Tasks")
              : TextField(
                  autofocus: taskService.isSearchVisible.value,
                  decoration: const InputDecoration(
                    hintText: 'Recherche...',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: taskService.filterByStatus);
        }),
        actions: [
          IconButton(
            onPressed: () {
              taskService.toggleSearchVisibility();
              if (!taskService.isSearchVisible.value) {
                taskService.filterByStatus("");
              }
              setState(() {});
            },
            icon: (taskService.isSearchVisible.value)
                ? Icon(Icons.close)
                : Icon(Icons.search),
          )
        ],
      ),
      body: Column(
        children: [
          buildLastSyncTime(),
          Expanded(
            child: Obx(() {
              if (taskService.filteredTasks.isEmpty) {
                return Center(child: CircularProgressIndicator());
              } else {
                return RefreshIndicator(
                  onRefresh: () async {
                    await taskService.syncDataFromServer();
                    setState(() {});
                  },
                  child: _buildList(taskService.filteredTasks),
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> tasks) {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(
        height: 10,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 5,
          margin: EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailScreen(task: tasks[index]),
                ),
              );
            },
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: Text(
                tasks[index]['Titre'] ?? "--",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              leading: Icon(Icons.assignment),
              trailing: Icon(Icons.arrow_forward_ios_outlined),
            ),
          ),
        );
      },
    );
  }

  Widget buildLastSyncTime() {
    String lastSyncText = 'Dernière Sync: ${taskService.getLastSyncDate()}';

    return Visibility(
      visible: taskService.getLastSyncDate() != null,
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
