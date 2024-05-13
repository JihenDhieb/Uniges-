import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uniges/modules/CRM/list_client_screen.dart';
import 'package:uniges/modules/UnigesManagement/ProjectManagement/add_project.dart';
import 'package:uniges/modules/UnigesManagement/ProjectManagement/add_tache.dart';
import 'package:uniges/modules/UnigesManagement/ProjectManagement/project_list.dart';
import 'package:uniges/modules/UnigesManagement/TaskManagement/task_list.dart';
import 'package:uniges/modules/home/login_page.dart';
import 'package:uniges/modules/home/home_page.dart';
import 'package:uniges/modules/home/onBoarding.dart';
import 'package:uniges/modules/home/register_page.dart';
import 'package:uniges/modules/settings/settings_screen.dart';
import 'package:uniges/modules/wms/Reception/BonDeReception.dart';
import 'package:uniges/modules/wms/Sortie/BonDeSortie.dart';
import 'package:uniges/modules/wms/screens/SOFDecoupe.dart';
import 'package:uniges/modules/wms/screens/collisage_container/collisage_containe_home.dart';
import 'package:uniges/modules/wms/inventaire/waitForInv.dart';
import 'package:uniges/modules/wms/SOFDecoupII/SOFDecoupeII_screen.dart';
import 'package:uniges/modules/wms/BSCH/BSCH_Screen.dart';
import 'package:uniges/modules/wms/screens/ExpCollisage.dart';
import 'package:uniges/modules/wms/screens/MouvementsStock.dart';
import 'package:uniges/modules/wms/screens/infoQRCode.dart';
import 'package:uniges/modules/wms/screens/reception_collisage.dart';
import 'package:uniges/modules/wms/tranfert_stock/transfert_page.dart';
import 'package:uniges/services/company_service.dart';
import 'package:uniges/services/dependency_injection.dart';
import 'package:uniges/services/httplogger.dart';
import 'package:uniges/modules/statistique/Stats_home.dart';
import 'package:uniges/modules/validation/screens/mainScreen.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'modules/Dashboard/Screens/dashboard_home.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

bool isAnyCompanyRegistred = false;
final dio = Dio();
dynamic androidId;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  androidId = await FlutterUdid.udid;
  await GetStorage.init();
  isAnyCompanyRegistred = Company.isCompanyRegistered();
  dio.interceptors.add(LoggingInterceptor());
  bool isProduction = const bool.fromEnvironment('dart.vm.product');
  HttpOverrides.global = MyHttpOverrides();

  if (isProduction) {
    SentryFlutter.init(
      (options) => options
        ..dsn =
            'https://550e2c2c58c644eb9ae18343b1c43fa5@glitchtip.demo.pmc.tn/1'
        ..tracesSampleRate = 0.01
        ..enableAutoSessionTracking = false,
      appRunner: () => runApp(const MainApp()),
    );
  } else {
    runApp(const MainApp());
  }
  DependencyInjection.init();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'UNIGES',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
        useMaterial3: true,
        primaryColor: const Color.fromARGB(255, 43, 94, 236),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[200],
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        fontFamily: 'Montserrat',
      ),
      initialRoute: (isAnyCompanyRegistred) ? '/' : '/onBoarding',
      getPages: [
        GetPage(name: '/onBoarding', page: () => const OnBoardingPage()),
        GetPage(name: '/register', page: () => CompanyRegistrationWidget()),
        GetPage(name: '/', page: () => const LoginScreen()),
        GetPage(name: '/menu', page: () => MenuScreen()),
        GetPage(name: '/validation', page: () => const MainScreenValidation()),
        GetPage(name: '/dashboard', page: () => const DashboardHome()),
        GetPage(name: '/Stat', page: () => const StatsHome()),
        GetPage(name: '/Settings', page: () => SettingsScreen()),
        GetPage(name: '/crm', page: () => listClientScreen()),
        GetPage(
            name: '/wms/container_colisage',
            page: () => const CollisageContainerHome()),
        GetPage(name: '/wms/transfer_page', page: () => TransfertPage()),
        GetPage(
            name: '/wms/reception_colisage', page: () => ReceptionCollisage()),
        GetPage(
            name: '/wms/exp_colisage',
            page: () => ExpCollisage(
                  status: 0,
                )),
        GetPage(
            name: '/wms/verif_colisage',
            page: () => ExpCollisage(
                  status: 1,
                )),
        GetPage(name: '/wms/inventaire', page: () => WaitForInvScan()),
        GetPage(name: '/wms/sof_decoupe2', page: () => SOFDecoupeIIScreen()),
        GetPage(name: '/wms/sof_decoupe1', page: () => SOFDecoupe()),
        GetPage(name: '/wms/bsch', page: () => BSCHScreen()),
        GetPage(name: '/wms/mouvements_stock', page: () => MouvementsStock()),
        GetPage(
            name: '/wms/reception_colisage', page: () => ReceptionCollisage()),
        GetPage(name: '/wms/infoQRCode', page: () => infoQrCodeScreen()),
        GetPage(name: '/wms/bonReception', page: () => BonDeReception()),
        GetPage(name: '/wms/bonSortie', page: () => BonDeSortie()),
        GetPage(name: '/TakManagement/task_list', page: () => ListTaskScreen()),
        GetPage(
            name: '/ProjectManagement/add_project',
            page: () => AddProjectScreen()),
        GetPage(
            name: '/ProjectManagement/add_tache', page: () => AddTaskScreen()),
        GetPage(
            name: '/ProjectManagement/project_list',
            page: () => listProjectScreen()),
      ],
    );
  }
}
/*
var menu = [
  {
    "name": "DASHBOARD",
    "path": "dashboard",
    "icon": "assets/icons/dashboard.svg"
  },
  {
    "name": "WMS",
    "children": [
      {"name": "Changement emplacement", "path": "WMS/ChangementEmplacement"},
      {"name": "Repositionner Article", "path": "RepositionnerArticle"},
      {"name": "Inventaire", "path": "Inventaire"},
      {"name": "Transfer Site", "path": "transferSite"},
      {"name": "Mouvements de Stock", "path": "MouvementsStock"},
      {"name": "Réception colisage", "path": "ReceptionCollisage"},
      {"name": "SOF Découpe", "path": "SOFDecoupe"},
      {"name": "SOF Collisage", "path": "Collisage"},
      {"name": "Expédition Collisage", "path": "WMS/expCollisage"},
    ],
    "icon": "assets/icons/wms.svg"
  },
  {
    "name": "CRM",
    "children": [
      {"name": "Clients", "path": "CRM/Clients"},
      {"name": "Tickets", "path": "CRM/Tickets"},
      {"name": "Dashboard", "path": "CRM/Dashboard"},
      //  {"name": "Chat", "path": "CRM/Chat"},
    ],
    "icon": "assets/icons/crm.svg"
  },
  {"name": "GRH", "path": "GRH", "icon": "assets/icons/grh.svg"},
  {"name": "GMAO", "path": "GMAO", "icon": "assets/icons/gmao.svg"},
  {"name": "Finance", "path": "Stat", "icon": "assets/icons/finance.svg"},
  {"name": "QC", "path": "QC", "icon": "assets/icons/qc.svg"},
  {
    "name": "VALIDATION",
    "path": "validation",
    "icon": "assets/icons/validation.svg"
  },
  {"name": "SETTINGS", "path": "Settings", "icon": "assets/icons/settings.svg"},
];
*/

var menu = [
  {
    "name": "DASHBOARD",
    "path": "dashboard",
    "icon": "assets/icons/dashboard.svg"
  },
  {
    "name": "VALIDATION",
    "path": "validation",
    "icon": "assets/icons/validation.svg"
  },
  {
    "name": "WMS",
    "children": [
      {"name": "Mouvements de Stock", "path": "MouvementsStock"},
      {"name": "Réception colisage", "path": "ReceptionCollisage"},
      {"name": "Expédition Collisage", "path": "WMS/expCollisage"},
      {"name": "Inventaire", "path": "WMS/inventaire"},
      {"name": "SOF Decoupe II", "path": "WMS/SOFDecoupeII"},
      {"name": "Bon Sortie CH", "path": "WMS/BSCH"},
      {"name": "SOF Découpe", "path": "SOFDecoupe"},
      {"name": "Réception colisage", "path": "WMS/ReceptionCollisage"},
      {"name": "Colisage Conteneur", "path": "WMS/ContainerCollisage"},
    ],
    "icon": "assets/icons/wms.svg"
  },
  {"name": "Finance", "path": "Stat", "icon": "assets/icons/finance.svg"},
  {"name": "CRM", "path": "crm", "icon": "assets/icons/crm.svg"},
  {"name": "SETTINGS", "path": "Settings", "icon": "assets/icons/settings.svg"},
];
