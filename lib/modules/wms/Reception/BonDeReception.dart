import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:uniges/modules/wms/Reception/ListDoc.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';

class BonDeReception extends StatefulWidget {
  const BonDeReception({super.key});
  @override
  State<BonDeReception> createState() => _BonDeReceptionState();
}

class _BonDeReceptionState extends State<BonDeReception>
    with WidgetsBindingObserver {
  bool isLoading = false;
  List? docD;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    ClipboardListenerObj.listeners.clear();
    ClipboardListenerObj.listeners.add(() async {
      onQRCodeScanned((await Clipboard.getData(Clipboard.kTextPlain))?.text);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Bon de réception'),
        ),
        body: Center(
            child: isLoading
                ? const SpinKitCircle(
                    color: Color.fromRGBO(165, 167, 168, 1),
                    size: 70,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                        const Text("Scanner le num du document",
                            style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 30),
                        // FloatingActionButton(
                        //     onPressed: qrCodeScanner,
                        //     child: const Icon(Icons.qr_code_2, size: 30))
                      ])));
  }

  onQRCodeScanned(code) async {
    setState(() {
      isLoading = true;
    });
    var ds = await UnigesService.tableRecherche('API_Doc', param: [code]);
    setState(() {
      isLoading = false;
    });

    if (ds == null || (ds["Document"] as List).isEmpty) {
      Fluttertoast.showToast(msg: "Impossible de trouver le document scanné");
      return;
    }

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ListDoc(ds)));
  }

  Future qrCodeScanner() async {
    await Permission.camera.request();
    String? cameraScanResult = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
    );

    // String? cameraScanResult = "CONS223194";
    if (cameraScanResult != null) {
      onQRCodeScanned(cameraScanResult);
    }
  }
}
