import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';
import 'package:uniges/widgets/demandeScanQrWidget.dart';

class infoQrCodeScreen extends StatefulWidget {
  const infoQrCodeScreen({super.key});

  @override
  State<infoQrCodeScreen> createState() => _infoQrCodeScreenState();
}

class _infoQrCodeScreenState extends State<infoQrCodeScreen>
    with WidgetsBindingObserver {
  bool _isInForeground = true;
  dynamic API_WMS_QRCode_Info;
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
    if (mounted) {
      getInfo(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Info QR Code"),
        ),
        body: (API_WMS_QRCode_Info == null)
            ? _buildScanScreen()
            : _buildQRCodeInfo());
  }

  Widget _buildScanScreen() {
    return DemandeScanQrCodewidget(
      key: UniqueKey(),
      onBtnCameraClick: onBtnCameraClick,
      title: "Test QR Code",
      decription: "Scanner Votre Code !",
    );
  }

  Widget _buildQRCodeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text("")),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: _buildRows(API_WMS_QRCode_Info[0]),
            ),
          ),
        ),
        Expanded(child: Text("")),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Scan un autre code ..."),
              const Text("ou"),
              ElevatedButton.icon(
                onPressed: onBtnCameraClick,
                icon: const Icon(
                  Icons.camera_alt,
                  size: 20,
                ),
                label: const Text("Camera"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRows(Map<String, dynamic> data) {
    List<Widget> rows = [];

    data.forEach((key, value) {
      rows.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$key :",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              "$value",
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      );
    });

    return rows;
  }

  Future<void> getInfo(code) async {
    API_WMS_QRCode_Info = await UnigesService.tableRecherche(
        "API_WMS_QRCode_Info",
        param: [code]);
    if (API_WMS_QRCode_Info == null || API_WMS_QRCode_Info == [])
      Fluttertoast.showToast(
          msg: "Veuillez scanner un QRCode Valide", textColor: Colors.red);

    setState(() {});
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
}
