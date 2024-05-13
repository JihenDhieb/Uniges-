import 'package:flutter/material.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/wms/tranfert_stock/display_information.dart';

import 'package:uniges/modules/wms/tranfert_stock/etiquette_caisse.dart';
import 'package:uniges/services/uniges_service.dart';

import 'package:uniges/widgets/QrCodeScanner.dart';
import 'package:uniges/widgets/demandeScanQrWidget.dart';

class TransfertPage extends StatefulWidget {
  const TransfertPage({super.key});

  @override
  _transfertPageState createState() => _transfertPageState();
}

class _transfertPageState extends State<TransfertPage>
    with WidgetsBindingObserver {
  bool adresseScanned = false;

  bool _isInForeground = true;

  Map<String, dynamic> data = {};

  TextEditingController CodeInterneController = TextEditingController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  initMethodChannel() {
    WidgetsBinding.instance.addObserver(this);
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      if (_isInForeground) {
        onQrCodeScan((await Clipboard.getData(Clipboard.kTextPlain))!.text);
      }
    });
  }

  @override
  void initState() {
    initMethodChannel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert'),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: DemandeScanQrCodewidget(
            title: "Scan QR Code",
            decription: "veuillez scanner le code QR pour continuer",
            onBtnCameraClick: _onCameraTap,
            key: UniqueKey(),
          )),
    );
  }

  void _onCameraTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
    );

    if (result != null) {
      onQrCodeScan(result);
    }
  }

  void onQrCodeScan(code) async {
    if (!adresseScanned && code != "") {
      if (mounted) {
        var _res = await UnigesService.tableRecherche("API_WMS_TRS_EmpContent",
            param: [code]);
        if (_res == null) {
          return;
        }

        setState(() {
          adresseScanned = true;
        });

        if (_res.isNotEmpty) {
          Get.off(() => DisplayInformationScreen(
                itemData: _res[0],
              ));
        } else {
          Get.off(() => EtiquetteCaisse(
                emplacement: code,
              ));
        }
      }
    }
  }
}
