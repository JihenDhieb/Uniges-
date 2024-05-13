import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uniges/modules/UnigesManagement/ProjectManagement/Kanban.dart';
import 'package:uniges/modules/home/login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uniges/services/OtaUpdate.dart';
import 'package:uniges/services/company_service.dart';
import 'package:uniges/services/uniges_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  dynamic menu;
  dynamic menuStructure;
  String status = "";

  @override
  void initState() {
    fetchMenu();

    super.initState();
  }

  Future<bool> IsAppUpToDate() async {
    try {
      String version = (await PackageInfo.fromPlatform()).buildNumber;

      dynamic appInfos = await UnigesService.getAppInfos();
      if (appInfos == null) return true;

      int _minVersion = appInfos["xApps_minVersion"];
      String lastVersionURL = appInfos["xApps_lastVersionURL"];

      if (_minVersion > int.parse(version)) {
        await FileDownload.downloadApk(
          lastVersionURL,
          'app.apk',
          (progressData) {
            setState(() {
              status =
                  "${progressData.status.toString()} : ${progressData.progress!} %";
            });
          },
        );
        return false;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  getChildren(var for_code) {
    print(for_code);
    return menu
        .where((element) => element["For_Parent"] == for_code)
        .map((x) => {
              "code": x["For_Code"],
              "name": x["For_Title"],
              "path": x["For_Path"],
              "icon": x["For_Icon"],
              "children": getChildren(x["For_Code"].toString())
            })
        .toList();
  }

  Future<void> fetchMenu() async {
    setState(() {
      status = "Vérification des mises à jour .. ";
    });

    if (!(await IsAppUpToDate())) {
      setState(() {
        status = "Impossible de télécharger la nouvelle version";
      });
      return;
    }

    setState(() {
      status = "Chargement du menu .. ";
    });

    GetStorage storage = GetStorage();
    menu = await UnigesService.tableRecherche("API_Menu_Mobile");
    if (menu != null && menu != []) {
      menuStructure = getChildren(null);
    }

    // if server doest return menu read it from storge
    if (menuStructure == null || menuStructure == []) {
      menuStructure = storage.read('menu_${SelectedCompany['name']}');
    } else {
      await storage.write('menu_${SelectedCompany['name']}', menuStructure);
    }
    setState(() {});
  }

  int i = 0;
  List<List<dynamic>> subMenuStack = [];

  void openSubMenu(List<dynamic> subMenu) {
    setState(() {
      subMenuStack.add(subMenu);
    });
  }

  void closeSubMenu() {
    setState(() {
      if (subMenuStack.isNotEmpty) subMenuStack.removeLast();
    });
  }

  Widget _buildMenuItem(dynamic menuItem) {
    final name = menuItem['name'];
    final path = menuItem['path'];
    final children = menuItem['children'] as List<dynamic>?;
    final iconPath = menuItem['icon'];
    final param = menuItem['param'] ?? {};

    i += 1;

    return GestureDetector(
      onTap: () {
        i = 0;
        if (children != null && children.isNotEmpty) {
          openSubMenu(children);
        } else {
          Get.toNamed('/$path', arguments: param);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              color: Colors.grey.shade300,
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (iconPath != null)
                SvgPicture.asset(
                  iconPath,
                  width: 50,
                  height: 50,
                ),
              Text(
                name.toString(),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(List<dynamic> menuItems) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      children: menuItems.map(_buildMenuItem).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSubMenu =
        subMenuStack.isNotEmpty ? subMenuStack.last : menuStructure;

    return Scaffold(
      //bottomNavigationBar: AppBarWidget(),
      appBar: AppBar(
        title: Text(SelectedCompany['name']),
        leading: IconButton(
          onPressed: closeSubMenu,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Voulez-vous vraiment vous déconnecter?'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: logOut,
                      child: const Text('Déconnecter'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('Annuler'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KanbanScreen()),
              );
            },
            icon: const Icon(Icons.calendar_today),
          ),
        ],
      ),
      body: (menuStructure == null || menuStructure == [])
          ? Center(
              child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(status),
                CircularProgressIndicator(),
              ],
            ))
          : _buildMenu(currentSubMenu),
    );
  }

  void logOut() {
    //employee = null;
    Get.to(LoginScreen(key: UniqueKey()));
  }
}
