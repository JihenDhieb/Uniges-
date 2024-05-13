import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/wms/BSCH/BSCH_BonReception.dart';
import 'package:uniges/modules/wms/BSCH/BSCH_BonReceptionST.dart';
import 'package:uniges/modules/wms/BSCH/BSCH_Document_Screen.dart';
import 'package:uniges/modules/wms/BSCH/BSCH_ScanOperateur.dart';

class BSCHScreen extends StatefulWidget {
  const BSCHScreen({super.key});

  @override
  State<BSCHScreen> createState() => _BSCHScreenState();
}

class _BSCHScreenState extends State<BSCHScreen> with WidgetsBindingObserver {
  bool _isInForeground = true;

  @override
  void initState() {
    initMethodChannel();

    super.initState();
  }

  @override
  void dispose() {
    ClipboardListenerObj.listeners.clear();
    super.dispose();
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

  void onQrCodeScan(code) async {
    if (mounted) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BS CH"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(height: 64),
            ElevatedButton(
              onPressed: () {
                _openDocument('PF');
              },
              child: Text('Créer un bon de sortie PF'),
            ),
            ElevatedButton(
              onPressed: () {
                _openDocument('SF');
              },
              child: Text('Créer un bon de sortie SF'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(BSCHBonReception());
              },
              child: Text('Créer un bon de réception'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(BSCHBonReceptionST());
              },
              child: Text('Créer un bon de réception S/T'),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void _openDocument(String type) {
    Get.to(BSCHScanperateur(document: type));
  }
}
