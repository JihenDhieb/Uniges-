import 'dart:convert';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uniges/constant/app_constant.dart';
import 'package:uniges/modules/wms/BSCH/BSCH_Screen.dart';
import 'package:uniges/services/uniges_service.dart';

class BSCHScanPieces extends StatefulWidget {
  final dynamic document;

  const BSCHScanPieces({super.key, required this.document});

  @override
  _S4ScanPiecesState createState() => _S4ScanPiecesState();
}

class _S4ScanPiecesState extends State<BSCHScanPieces>
    with WidgetsBindingObserver {
  List<Map<String, String>> _scannedElements = [];
  List<Map<String, dynamic>> _affichageList = [];

  bool _isInForeground = true;

  initMethodChannel() {
    WidgetsBinding.instance.addObserver(this);
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      if (_isInForeground)
        onQrCodeScan(
            (await Clipboard.getData(Clipboard.kTextPlain))!.text.toString());
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
  void initState() {
    try {
      initMethodChannel();
    } catch (e) {}
    super.initState();
  }

  _save() async {
    if (_scannedElements.isEmpty) {
      Fluttertoast.showToast(
        msg: "Impossible d'enregistrer un bon vide",
        backgroundColor: Colors.red,
      );
      return;
    }

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
                    child: new Text("Enregistrement en cours ..")),
              ],
            ),
          ),
        );
      },
    );

    try {
      var res = (await UnigesService.tableRecherche("API_BlocageBS2", param: [
        widget.document["siteDestination"],
        widget.document["site"],
        widget.document["chauffeur"],
        widget.document["camion"],
        widget.document["operateur"]
      ]));

      if (res!.isEmpty) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Erreur de connexion au serveur !",
            backgroundColor: Colors.red);
        return;
      }

      if (res[0]["Blocage"] == "true") {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: res[0]["Message"], backgroundColor: Colors.red);
        return;
      }

      var _requestBody = {
        "Document": [
          {
            "Doc_Num": "",
            "Tiers_code": widget.document["siteDestination"],
            "Doc_Type": "BSCH",
            "Site_Code": widget.document["site"],
            "Doc_Param3": widget.document["chauffeur"],
            "Doc_Param2": widget.document["camion"],
            "Doc_Param4": widget.document["operateur"],
            "Doc_Param5": widget.document["type"]
          }
        ],
        "DocumentD": _scannedElements
            .map((x) => {
                  "DocD_Id": "",
                  "Art_Code": "MAT",
                  "DocD_site": widget.document["site"],
                  "DocD_Q": x["DocD_Q"],
                  "DocD_Variante1": x["DocD_Variante1"],
                  "DocD_Variante2": x["DocD_Variante2"],
                  "DocD_Lot": x["DocD_Variante2"],
                })
            .toList()
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
    } catch (e) {
      print(e);
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Erreur 0x000074e6", backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _save,
          child: Icon(Icons.done),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 14,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 14,
                        bottom: 14,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Opérateur: ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: widget.document["operateur"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Chauffeur: ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: widget.document["chauffeur"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'Camion: ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: widget.document["camion"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          RichText(
                            text: TextSpan(
                              text: 'ID Site Destination: ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: widget.document["siteDestination"],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text('Veuillez scanner les paquets'),
                SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var article in _affichageList)
                            Container(
                              width: double.infinity,
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Text(
                                      "${article['Qte'].toString()} x ${article['OF_Num']}"),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  String decodeQRCode(String encryptedQRCode) {
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
      throw e;
    }
  }

  void onQrCodeScan(String input) async {
    String code = "";
    try {
      code = decodeQRCode(input);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Veuillez entrer un code officiel",
        backgroundColor: Colors.red,
      );
      return;
    }
    if (code == "") return;

    try {
      if (_scannedElements
          .where((element) => element["DocD_Variante2"] == code)
          .isNotEmpty) {
        Fluttertoast.showToast(
          msg: "Ce QRCode a été déjà scanné",
          backgroundColor: Colors.red,
        );
        return;
      }

      String ofnum = code.split(";")[0];
      String numPiece = code.split(";")[1];
      int qte = code.split(";").length > 2 ? int.parse(code.split(";")[2]) : 1;

      try {
        var res =
            await UnigesService.tableRecherche("API_BSBlocageArticle", param: [
          ofnum,
          numPiece,
          code.replaceAll(';', "~"),
          widget.document["type"],
          widget.document["site"]
        ]);
        if (res![0]["msg"] != "") {
          Fluttertoast.showToast(
              msg: res[0]["msg"], backgroundColor: Colors.red);
          return;
        }
      } catch (e) {
        Sentry.captureException(e);
        Fluttertoast.showToast(
            msg: "Impossible de se connecter au serveur 0x000071DA " +
                e.toString(),
            backgroundColor: Colors.red);
        return;
      }

      _scannedElements.add({
        "DocD_Variante2": code,
        "DocD_Variante1": ofnum,
        "DocD_Q": qte.toString()
      });

      setState(() {
        Map<String, dynamic> temp = _affichageList.firstWhere(
            (element) => element["OF_Num"] == ofnum,
            orElse: () => {});

        if (temp.isEmpty) {
          _affichageList.add({"OF_Num": ofnum, "Qte": qte});
        } else {
          temp["Qte"] += qte;
        }
      });
    } catch (e) {
      print(e);
      Sentry.captureException(e);
      Fluttertoast.showToast(
          msg: "Un erreur est survenu " + e.toString(),
          backgroundColor: Colors.red);
    }
  }
}
