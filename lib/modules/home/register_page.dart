import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/home/login_page.dart';
import 'package:uniges/services/company_service.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';
import 'package:uniges/widgets/demandeScanQrWidget.dart';

class CompanyRegistrationWidget extends StatefulWidget {
  @override
  _CompanyRegistrationWidgetState createState() =>
      _CompanyRegistrationWidgetState();
}

class _CompanyRegistrationWidgetState extends State<CompanyRegistrationWidget> {
  @override
  void initState() {
    initMethodChannel();

    super.initState();
  }

  void registerCompany(String name, String api) async {
    if (name.isNotEmpty && api.isNotEmpty) {
      Map<String, dynamic> newCompany = {'name': name, 'api': api};
      if (Company.registerCompany(newCompany)) {
        Fluttertoast.showToast(
            msg: "La société  $name a été ajouter avec succès",
            backgroundColor: Colors.green);
        setState(() {});
      } else {
        Fluttertoast.showToast(
            msg: "erreur d'enregistrement", backgroundColor: Colors.red);
      }
    } else {
      Fluttertoast.showToast(
          msg: "erreur d'enregistrement", backgroundColor: Colors.red);
    }
  }

  initMethodChannel() {
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      onQrCodeScan((await Clipboard.getData(Clipboard.kTextPlain))!.text);
    });
  }

  @override
  void dispose() {
    ClipboardListenerObj.listeners.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      floatingActionButton: Visibility(
        visible: Company.isCompanyRegistered(),
        child: FloatingActionButton.extended(
            onPressed: () {
              Get.to(() => LoginScreen());
            },
            label: Text("Login")),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5.0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 16,
                  ),
                  Image.asset(
                    'assets/icons/logo.png',
                    height: 80,
                    width: 120,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Ajouter une société',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  _buildScanScreen()
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildScanScreen() {
    return DemandeScanQrCodewidget(
      key: UniqueKey(),
      onBtnCameraClick: onBtnCameraClick,
      title: "",
      decription: "Scanner un QR Code",
    );
  }

  void onBtnCameraClick() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
    );

    if (result != null) {
      onQrCodeScan(result);
    }
  }

  void onQrCodeScan(code) async {
    if (mounted) {
      String? result;

      if (!kDebugMode) {
        result = UnigesService.decodeQRCode(code);
      } else {
        result = code;
      }

      if (result != null) {
        var variables = result.split('~');
        if (variables.length > 2) registerCompany(variables[1], variables[2]);
      }
    }
  }
}
