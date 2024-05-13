import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:uniges/constant/app_constant.dart';
import 'package:uniges/main.dart';
import 'package:uniges/modules/wms/BSCH/BSCH_Screen.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';
import 'package:uniges/widgets/demandeScanQrWidget.dart';
import 'package:http/http.dart';

class BSCHBonReceptionST extends StatefulWidget {
  @override
  _BSCHBonReceptionSTState createState() => _BSCHBonReceptionSTState();
}

class _BSCHBonReceptionSTState extends State<BSCHBonReceptionST>
    with WidgetsBindingObserver {
  String docNum = "";
  dynamic documentD;

  loadBS(docNum) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: new Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: new Text("Chargement du BS ..")),
              ],
            ),
          ),
        );
      },
    );

    documentD = await UnigesService.tableRecherche("API_ChargerBS",
        param: [docNum, androidId]);

    Navigator.of(context).pop();

    if (documentD.isEmpty) {
      Fluttertoast.showToast(
        msg: "Le bon scanné ne vous appartient pas",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    } else {
      this.docNum = docNum;
    }

    setState(() {});
  }

  @override
  void initState() {
    initMethodChannel();

    super.initState();
  }

  bool _isInForeground = true;

  initMethodChannel() {
    WidgetsBinding.instance.addObserver(this);
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      if (_isInForeground)
        onQrCodeScan((await Clipboard.getData(Clipboard.kTextPlain))!.text);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text('Bon de récpetion'),
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: _save, child: Icon(Icons.check)),
      body: (docNum == '')
          ? Center(
              child: DemandeScanQrCodewidget(
                  onBtnCameraClick: onBtnCameraClick,
                  title: "",
                  decription: "Veuillez scanner le bon de sortie"))
          : ListView.builder(
              itemCount: documentD.length,
              itemBuilder: (context, i) {
                var item = documentD[i];
                return Card(
                    child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(item["DocD_Q"].floor().toString()),
                      SizedBox(width: 20),
                      Expanded(child: Text(item["Art_Des"])),
                    ],
                  ),
                ));
              }),
    ));
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

  void onQrCodeScan(code) {
    loadBS(code);
  }

  void _save() async {
    var doc = await UnigesService.dsGet("BSCHValidation", param: [docNum]);

    List<dynamic> ss_sites = await UnigesService.tableRecherche(
        "API_BS_SousSites",
        param: [documentD.first["Tiers_code"]]);

    String? site_code_reception;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Veuillez choisir le site de réception"),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: ss_sites
                  .map((site) => ElevatedButton(
                      onPressed: () {
                        site_code_reception = site["Site_Code"];
                        Navigator.of(context).pop();
                      },
                      child: Text(site["Site_Code"])))
                  .toList()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );

    if (site_code_reception == null) return;

    var _requestBody = {
      "Document": [
        {
          "Doc_Num": "",
          "Tiers_code": site_code_reception,
          "Doc_Type": "BSCH",
          "Doc_Valide": 1,
          "Doc_ref": doc["Document"][0]["Doc_Num"],
          "Site_Code": doc["Document"][0]["Tiers_code"],
        }
      ],
      "DocumentD": documentD
    };

    try {
      var _res = await post(
          Uri.parse("${AppConstants().baseUrl}/document/postdocsimple"),
          headers: AppConstants().jsonHEADERS,
          body: jsonEncode(_requestBody));

      if (_res.statusCode < 300) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Enregistrement terminé", backgroundColor: Colors.green);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => BSCHScreen(),
            ),
            (route) => false);
      } else {
        Fluttertoast.showToast(
            msg: "Erreur d'enregistrement ", backgroundColor: Colors.red);
        return;
      }
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Veuillez vérifier votre connexion internet",
          backgroundColor: Colors.red);
      return;
    }

    //await dataBox.add(docNum + ";" + site_code_reception);
    Fluttertoast.showToast(
        msg: "Réception validé", backgroundColor: Colors.green);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => BSCHScreen()));
  }
}
