import 'dart:math';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uniges/main.dart';
import 'package:uniges/services/UiService.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';

class AddSofScreen extends StatefulWidget {
  final String ofNum;
  final String siteCode;
  const AddSofScreen({super.key, required this.ofNum, required this.siteCode});

  @override
  _AddSofScreenState createState() => _AddSofScreenState();
}

class _AddSofScreenState extends State<AddSofScreen>
    with WidgetsBindingObserver {
  List<dynamic> ofd = [];
  dynamic ofdn = {};
  String? ofNum;
  String? bobineLot;
  double bobinePoids = 0.0;

  bool _isInForeground = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Ajouter SOF Coupe'),
          actions: [
            GestureDetector(
              child: Icon(Icons.qr_code),
              onTap: onBtnCameraClick,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _save,
          child: Icon(Icons.save_rounded),
        ),
        body: bobineLot == null
            ? Center(child: Text("Veuillez scanner une bobine"))
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.article_outlined),
                              SizedBox(
                                width: 10,
                              ),
                              Text(ofNum ?? "")
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.settings_outlined),
                              SizedBox(
                                width: 10,
                              ),
                              Text(ofdn["OFDN_Composant"])
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                    itemCount: ofd.length,
                    itemBuilder: _rowTemplate,
                  )),
                  /*Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green)),
                onPressed: () {},
                child: Text('Valider'),
              ),
            ),*/
                ],
              ),
      ),
    );
  }

  _openQteDialog(item) {
    String qte = '';

    showDialog(
      context: context,
      barrierDismissible:
          false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item["OFD_DesArticle"]),
          content: new Row(
            children: [
              new Expanded(
                  child: new TextField(
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: new InputDecoration(
                    labelText: 'Quantité',
                    hintText: item["OFD_QScan"].toString()),
                onChanged: (value) {
                  qte = value;
                },
              ))
            ],
          ),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(qte);
              },
            ),
          ],
        );
      },
    ).then((value) {
      setState(() {
        double a = double.parse(value);

        // if (a <= item["OFD_Q"] - item["OFD_QR"]) {
        item["OFD_QScan"] = a;
        // } else {
        //   CustomTheme.showErrorSnackBar(
        //       msg: "La quantité n'est pas commandée",
        //       toastLength: Toast.LENGTH_LONG,
        //       backgroundColor: Colors.red);
        // }
      });
    });
  }

  Widget _rowTemplate(BuildContext context, int index) {
    var item = ofd.elementAt(index);

    return InkWell(
      onTap: () {
        _openQteDialog(item);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    child: Text(
                      '${double.parse(item['OFD_QScan'].toString()).toStringAsFixed(2)} / ${double.parse((item['OFD_Q'] - item['OFD_QR']).toString()).toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(item['OFD_DesArticle']),
                ],
              ),
              Row(
                children: [
                  Text(
                      '${item['Art_Car1']} x ${item['Art_Car2']} x ${item['Art_Car3']}  ')
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    try {
      initMethodChannel();
    } catch (e) {}

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      tryLoadDC(widget.ofNum);
    });
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

  void tryLoadDC(_ofNum) async {
    CustomTheme.showLoadingDialog(loadingMessage: "Chargement de la DC");

    print(_ofNum);
    ofd = await UnigesService.tableRecherche("API_SOFCoupe_ChargerDC",
            param: [_ofNum]) ??
        [];

    ofdn = (await UnigesService.tableRecherche("API_SOFCoupe_ChargerOFDN",
        param: [_ofNum]))![0];

    Navigator.of(context).pop();

    this.ofNum = _ofNum;

    ofd.forEach((element) {
      element["OFD_QScan"] = 0;
    });
    setState(() {});
  }

  void _save() async {
    try {
      var qteTotalConsommeBobine = 0.0;

      ofd.forEach((element) {
        qteTotalConsommeBobine +=
            double.parse(element["OFD_QScan"].toString()) *
                double.parse(element["Art_Car1"].toString()) *
                double.parse(element["Art_Car2"].toString()) *
                double.parse(element["Art_Car3"].toString()) *
                7.85;
      });

      if (qteTotalConsommeBobine == 0.0) {
        CustomTheme.showErrorSnackBar(
            "Impossible d'entregistrer un suivi vide");
        return;
      }

      if (qteTotalConsommeBobine > bobinePoids * 1.02) {
        CustomTheme.showErrorSnackBar(
            "Poids produit ( $qteTotalConsommeBobine ) supérieur au poids restant de la bobine ( $bobinePoids ) ");
        return;
      }

      bool isSolde = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: [
              ElevatedButton(
                child: Text('Solder la bobine'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
              TextButton(
                child: Text('Non'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
            content: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Voulez-vous solder la bobine ?"),
            ),
          );
        },
      );

      var req = await UnigesService.tableRecherche("API_PDAProfile",
          param: [androidId]);
      if (req == null || req.isEmpty) {
        Fluttertoast.showToast(
            msg: "L'ID " + androidId + " n'est pas configuré !",
            backgroundColor: Colors.red);
        return;
      }

      String current_site = req[0]["Site_Code"];

      var payload = {
        "ApiSOF": [
          {
            "OFSParam_Code": "DC",
            "OF_Num": ofNum,
            "OFSD_Q": 1,
            "OFS_Q": 1,
            "OFS_TypeNom": 0
          }
        ],
        "OFSD": ofd
            .where((element) => element["OFD_QScan"] > 0)
            .map((e) => {
                  "of_Num": ofNum,
                  "OFD_Id": e["OFD_Id"],
                  "OFSD_Q": e["OFD_QScan"],
                  "Art_Code": e["Art_Code"],
                  "Art_Car1": e["Art_Car1"],
                  "Art_Car2": e["Art_Car2"],
                  "Art_Car3": e["Art_Car3"],
                  "Art_Car5": e["Art_Car5"],
                  "OFSD_Lot": bobineLot,
                  "Site_Code": current_site,
                  "OFSD_Statut": "A"
                })
            .toList(),
        "OFSN": [
          {
            "OF_Num": ofNum,
            "OFSN_Composant": ofdn["OFDN_Composant"],
            "OFSN_ComposantDes": ofdn["OFDN_ComposantDes"],
            "OFSN_Q": min(qteTotalConsommeBobine, bobinePoids),
            "OFSN_Statut": "A",
            "OFSN_Solde": isSolde,
            "OFSN_Variante1": ofdn["OFDN_Variante1"],
            "OFSN_Variante2": ofdn["OFDN_Variante2"],
            "OFSN_Variante3": ofdn["OFDN_Variante3"],
            "OFSN_Variante5": ofdn["OFDN_Variante5"],
            "OFSN_Lot": bobineLot,
            "OFSN_Unite": "KG",
            "OFSN_UniteN": "KG",
            "Site_Code": widget.siteCode
          }
        ]
      };

      if (isSolde) {
        if (qteTotalConsommeBobine < bobinePoids * 0.98) {
          CustomTheme.showErrorSnackBar(
              "Poids produit ( $qteTotalConsommeBobine ) inférieur au poids restant de la bobine ( $bobinePoids ) ");
          return;
        }

        double? longueurDerniereTole = await showDialog<double>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            double v = 0.0;
            return AlertDialog(
              title: Text("Saisie la longueur de la dernière pièce"),
              content: new Row(
                children: [
                  new Expanded(
                      child: new TextField(
                    autofocus: true,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: new InputDecoration(
                        labelText: 'Longueur en mètres',
                        hintText: "Longueur en mètres"),
                    onChanged: (value) {
                      v = double.parse(value);
                    },
                  ))
                ],
              ),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(v);
                  },
                ),
              ],
            );
          },
        );

        double poidsFinBobine = longueurDerniereTole! *
            double.parse(ofdn["OFDN_Variante2"]) *
            double.parse(ofdn["OFDN_Variante3"]) *
            7.85;

        if (qteTotalConsommeBobine + poidsFinBobine > bobinePoids * 1.02) {
          CustomTheme.showErrorSnackBar(
              "Poids produit ( ${qteTotalConsommeBobine + poidsFinBobine} ) supérieur au poids de la bobine ( $bobinePoids ) ");
          return;
        }

        payload["OFSN"]!.add({
          "OF_Num": ofNum,
          "OFSN_Composant": ofd[0]["Art_Code"],
          "OFSN_ComposantDes": "Tole restante",
          "OFSN_Q": -1,
          "OFSN_Statut": "A",
          "OFSN_Solde": 0,
          "OFSN_Variante1": longueurDerniereTole,
          "OFSN_Variante2": ofd[0]["Art_Car2"],
          "OFSN_Variante3": ofd[0]["Art_Car3"],
          "OFSN_Variante5": ofd[0]["Art_Car5"],
          "OFSN_Lot": bobineLot,
          "OFSN_Unite": "PCE",
          "OFSN_UniteN": "PCE",
          "Site_Code": widget.siteCode
        });
      }

      CustomTheme.showLoadingDialog(
          loadingMessage: "Enregistrement en cours ..");

      if (await UnigesService.dsSkgPost(payload)) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        CustomTheme.showSuccessSnackBar("Enregistrement effectué avec succès");
      } else {
        Navigator.of(context).pop();
        CustomTheme.showErrorSnackBar("Erreur d'enregistrement SOF 0x0001F6A");
      }
    } catch (e) {
      Sentry.captureException(e);
      CustomTheme.showErrorSnackBar(e.toString());
    }
  }

  Future<void> onBtnCameraClick() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
    );

    if (result != null) {
      onQrCodeScan(result);
    }
  }

  String? decodeQRCode(String encryptedQRCode) {
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

  void onQrCodeScan(qrcode) async {
    bobineLot = decodeQRCode(qrcode)!.split(";")[1];

    if (bobineLot == null) {
      CustomTheme.showErrorSnackBar("Veuillez scanner un QRCode officiel");
      return;
    }

    CustomTheme.showLoadingDialog(loadingMessage: "Vérification de la bobine");
    var r = await UnigesService.tableRecherche("API_SOFCoupe_ChargerBobine",
        param: [bobineLot!, widget.siteCode]);
    Navigator.of(context).pop();

    if (r!.length == 0) {
      CustomTheme.showErrorSnackBar(
          "La bobine est inexistante ou n'appartient pas à ce site");
      return;
    } else if (r[0]["Art_Code"] != ofdn["OFDN_Composant"]) {
      CustomTheme.showErrorSnackBar("Bobine incorrecte");
      return;
    } else {
      setState(() {
        bobineLot = r[0]["Sto_Lot"];
        bobinePoids = r[0]["Sto_Q"];
      });
    }
  }
}
