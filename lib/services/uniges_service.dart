import 'dart:convert';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:intl/intl.dart';
import 'package:uniges/main.dart';
import '../constant/app_constant.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:package_info_plus/package_info_plus.dart';

// ignore: prefer_typing_uninitialized_variables
var token;

class UnigesService {
  static Future<List<dynamic>?> getTRColumns(tablere) async {
    try {
      dio.options.headers = AppConstants().jsonHEADERS;
      var url =
          '${AppConstants().baseUrl}/recherche/TbRecherche?param=$tablere';
      var res = await dio.get(url);
      return jsonDecode(res.data)["TableRD"];
    } catch (e) {
      return null;
    }
  }

  static Future<dynamic> tableRecherche(tablere,
      {List<String> param = const [], String? baseUrl}) async {
    String params = param.join(',');

    if (baseUrl == null) baseUrl = AppConstants().baseUrl;

    try {
      dio.options.headers = AppConstants().jsonHEADERS;
      var url = '${baseUrl}/recherche/tbdata?tablere=$tablere';
      if (param.isNotEmpty) url += '&param=$params';
      print(url);
      var res = await dio.get(url);
      print(res);
      return jsonDecode(res.data);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> dsPostgetCode(body) async {
    try {
      dio.options.headers = AppConstants().jsonHEADERS;
      var res = await dio.post('${AppConstants().baseUrl}/ds/post', data: body);
      print(jsonDecode(res.data));
      return jsonDecode(res.data)["code"];
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<dynamic> dsGet(code, {List<String> param = const []}) async {
    String params = param.join(',');

    try {
      dio.options.headers = AppConstants().jsonHEADERS;
      var url = '${AppConstants().baseUrl}/ds/formdata?code=$code';
      if (param.isNotEmpty) url += '&val=$params';

      var res = await dio.get(url);

      return json.decode(res.data);
    } catch (e) {
      return null;
    }
  }

  static String? decodeQRCode(String encryptedQRCode) {
    try {
      final key = encrypt.Key.fromUtf8('Q#w)m2Fgc*(&KkA8');
      final iv = encrypt.IV.fromSecureRandom(16);

      final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.ecb, padding: null));

      String temp = encrypter.decrypt64(encryptedQRCode, iv: iv);

      String res = "";
      for (int i = 0; i < temp.length; i++) {
        if (temp.codeUnits[i] >= 32) {
          res += temp[i];
        }
      }

      return res;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static String replaceEmptyString(var input) {
    if (input == null || input == "") {
      return "--";
    } else {
      return input.toString();
    }
  }

  static String formatNumberWithSpaces(num number) {
    String num = number.toStringAsFixed(3);
    if (num == "0.000" || num == "-0.000") return "0.000";
    final formatter = NumberFormat('###,###.000', 'en_US');
    final formattedNumber = formatter.format(number);
    return formattedNumber.replaceAll(',', ' ');
  }

  static Future<bool> dsPost(body) async {
    print(body);
    try {
      dio.options.headers = AppConstants().jsonHEADERS;
      var res = await dio.post('${AppConstants().baseUrl}/ds/post', data: body);
      if (res.statusCode! < 300) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> dsPostImage(body) async {
    print(body);
    try {
      dio.options.headers = AppConstants().jsonHEADERS;
      var res =
          await dio.post('${AppConstants().baseUrl}/ds/uploadFile', data: body);
      if (res.statusCode! < 300) return true;
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> login(String username, String password) async {
    try {
      var url = '${AppConstants().baseUrl}/users/login';
      var res = await dio
          .post(url, data: {"username": username, "password": password});
      var response = res.data;
      token = response["accessToken"];
      return response["success"];
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> dsSkgPost(body) async {
    print(body);
    try {
      dio.options.headers = AppConstants().jsonHEADERS;
      var res =
          await dio.post('https://srv-msgi.pmc.tn/api/skg/post', data: body);
      print(res.data);
      print(res.statusCode);
      if (res.statusCode! < 300) return true;
      return false;
      //return jsonDecode(res.body);
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> DocPost(body) async {
    try {
      dio.options.headers = AppConstants().jsonHEADERS;
      var res = await dio
          .post('${AppConstants().baseUrl}/document/postdocsimple', data: body);
      if (res.statusCode! < 300) return true;
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<dynamic> getAppInfos() async {
    var res = await UnigesService.tableRecherche("API_xApps",
        param: [(await PackageInfo.fromPlatform()).packageName]);
    try {
      return res!.elementAt(0);
    } catch (e) {
      return null;
    }
  }
}
