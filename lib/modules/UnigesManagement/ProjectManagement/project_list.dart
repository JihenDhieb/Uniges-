import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/UnigesManagement/ProjectManagement/details_project.dart';
import 'package:uniges/modules/UnigesManagement/ProjectManagement/project_service.dart';

class listProjectScreen extends StatefulWidget {
  @override
  State<listProjectScreen> createState() => _listProjectScreenState();
}

class _listProjectScreenState extends State<listProjectScreen> {
  final ProjectService projectService = Get.put(ProjectService());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          return (!projectService.isSearchVisible.value)
              ? Text("Projets")
              : TextField(
                  autofocus: projectService.isSearchVisible.value,
                  decoration: const InputDecoration(
                    hintText: 'Recherche...',
                    border: UnderlineInputBorder(),
                  ),
                  onChanged: projectService.filterProjects);
        }),
        actions: [
          IconButton(
              onPressed: () {
                projectService.toggleSearchVisibility();
                if (!projectService.isSearchVisible.value) {
                  projectService.filterProjects("");
                }
                setState(() {});
              },
              icon: (projectService.isSearchVisible.value)
                  ? Icon(Icons.close)
                  : Icon(Icons.search))
        ],
      ),
      body: Column(
        children: [
          buildLastSyncTime(),
          Expanded(
            child: Obx(() {
              if (projectService.filteredProjects.isEmpty) {
                return Center(child: CircularProgressIndicator());
              } else {
                return RefreshIndicator(
                    onRefresh: () async {
                      await projectService.syncDataFromServer();
                      setState(() {});
                    },
                    child: _buildList(projectService.filteredProjects));
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> projects) {
    return ListView.separated(
      separatorBuilder: (context, index) => SizedBox(
        height: 10,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: 100,
            child: _buildListItem(projects[index]));
      },
    );
  }

  Widget _buildListItem(dynamic project) {
    final title = project['Titre'] ?? "--";
    final subTitle = project['Title'] ?? "--";

    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectDetailsScreen(
                titre: project['Titre'],
                description: project['Description'],
                dateCreation: project['DateCreation'],
                tiers: project['Tiers'],
                statut: project['Statu'],
                dateEcheance: project['DateEcheance'],
                payant: project['Payant'],
                idProjet: project['idProjet'],
              ),
            ),
          );
        },
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          leading: Icon(Icons.data_usage_sharp),
          trailing: Icon(Icons.arrow_forward_ios_outlined),
        ),
      ),
    );
  }

  Widget buildLastSyncTime() {
    String lastSyncText = 'Dernière Sync: ${projectService.getLastSyncDate()}';

    return Visibility(
      visible: projectService.getLastSyncDate() != null,
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
