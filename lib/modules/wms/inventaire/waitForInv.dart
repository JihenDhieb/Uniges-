import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uniges/modules/wms/inventaire/listItems.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';
import 'package:uniges/widgets/demandeScanQrWidget.dart';

class WaitForInvScan extends StatefulWidget {
  const WaitForInvScan({Key? key}) : super(key: key);

  @override
  _WaitForInvScanState createState() => _WaitForInvScanState();
}

class _WaitForInvScanState extends State<WaitForInvScan> {
  onQrCodeScan(String? code) {
    Navigator.of(context)
        .pushReplacement(
          MaterialPageRoute(
            builder: (e) => ItemsListScreen(
              invCode: code,
            ),
          ),
        )
        .then((_) {});
  }

  initChannelMethod() {
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      onQrCodeScan((await Clipboard.getData(Clipboard.kTextPlain))?.text);
    });
  }

  @override
  void initState() {
    super.initState();
    initChannelMethod();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventaire"),
      ),
      /*floatingActionButton: FloatingActionButton(
          onPressed: openCamera, child: Icon(Icons.camera_alt_rounded)),*/
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DemandeScanQrCodewidget(
                key: UniqueKey(),
                onBtnCameraClick: onBtnCameraClick,
                title: "",
                decription: "Scanner Votre Inventaire !"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => onQrCodeScan(null),
          label: Text("Créer un nouveau inventaire")),
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

  void openCamera() async {
    if (!(await Permission.camera.request()).isGranted) {
      Fluttertoast.showToast(msg: "Permission caméra est nécessaire");
      return;
    }

    /*String? qrCode = await scanner.scan();

    if (qrCode != null) {
      onQrCodeScan(qrCode);
    }*/
  }
}
