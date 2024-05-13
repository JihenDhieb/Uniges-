import 'package:uniges/services/company_service.dart';
import 'package:uniges/services/uniges_service.dart';

class AppConstants {
  // static String baseUrl = "http://srv2-msgi.pmc.tn/api";//
  String baseUrl = "${SelectedCompany['api']}/api"; //
  //static String baseUrl = "http://161.97.88.210:5005/api";
  //static String baseUrl = "https://sipasud.proxy.pmc.tn/api";
  //static String baseUrl = "http://192.168.1.242:82/api"; // SuperFood
  Map<String, String> jsonHEADERS = {
    "Content-type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Authorization": 'Bearer $token'
  };
}
