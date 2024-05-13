import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';

class ItemsListScreen extends StatefulWidget {
  final String? invCode;
  const ItemsListScreen({Key? key, required this.invCode}) : super(key: key);

  @override
  _ItemsListScreenState createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  List<dynamic> _scannedItems = [];

  onQrCodeScan(String? code) async {
    if (code == null) return;

    //code = UnigesService.decodeQRCode(code);

    /*if (code == null) { // Pour MSGI
      Fluttertoast.showToast(msg: "Merci de scanner un QRCode officiel");
      return;
    }*/

    try {
      // String separator = ";";

      // List<String> keys = ["Art_Code", "Sto_Lot"];
      // List<String> values = code!.split(separator);

      var itemInfo =
          await UnigesService.tableRecherche("API_Inv_ItemInfo", param: [code]);

      if (itemInfo == null || itemInfo.isEmpty) {
        Fluttertoast.showToast(msg: "Code incorrect");
        return;
      }

      Map<String, dynamic> obj = itemInfo[0];
      obj["Inv_Code"] = widget.invCode;
      obj["Sto_Statut"] = "A";

      // Special MAMIX
      /*Map<String, dynamic> obj = {
        "Art_Code": code,
        "Inv_Code": widget.invCode,
        "Sto_Statut": "A"
      };*/

      // -------

      if (!obj.containsKey("InvDC_Q")) {
        double? v = await _openQteDialog(obj);
        obj["InvDC_Q"] = v?.toStringAsFixed(3);
      }

      setState(() {
        _scannedItems.add(obj);
      });
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "Impossible d'ajouter cet article " + e.toString());
    }
  }

  Future<double?> _openQteDialog(item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double nbCartons = 0.0, nbUnits = 1.0, nbVrac = 0.0;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Saisie quantité"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Nombre de colis"),
                    onChanged: (v) {
                      try {
                        nbCartons = double.parse(v);
                      } catch (e) {}
                      setState(() {});
                    },
                  ),
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(hintText: "Nombre de pièces par colis"),
                    onChanged: (v) {
                      try {
                        nbUnits = double.parse(v);
                      } catch (e) {}

                      setState(() {});
                    },
                  ),
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(hintText: "Nombre de pièces séparées"),
                    onChanged: (v) {
                      try {
                        nbVrac = double.parse(v);
                      } catch (e) {}
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Ajouter ${nbCartons * nbUnits + nbVrac}'),
                onPressed: () {
                  Navigator.of(context).pop(nbCartons * nbUnits + nbVrac);
                },
              ),
            ],
          );
        });
      },
    ).then((v) {
      setState(() {
        item["InvDC_Q"] = v;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      onQrCodeScan((await Clipboard.getData(Clipboard.kTextPlain))?.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invCode ?? "Nouveau inventaire"),
        actions: [
          GestureDetector(
            child: Icon(Icons.check),
            onTap: saveInv,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: openCamera, child: Icon(Icons.camera_alt_rounded)),
      body: Container(
        child: ListView.builder(
          itemCount: _scannedItems.length,
          itemBuilder: _rowTemplate,
        ),
      ),
    );
  }

  Widget _rowTemplate(BuildContext context, int index) {
    Map<String, dynamic> item = _scannedItems.elementAt(index);

    return Container(
      child: InkWell(
        onTap: () async {
          double? v = await _openQteDialog(item);
          item["InvDC_Q"] = v?.toStringAsFixed(3);
        },
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
                "${item["InvDC_Q"].toString()}  x   ${item["Art_Code"]}   -     ${item["Sto_Lot"]} "),
          ),
        ),
      ),
    );
  }

  //TODO : article déjà scanné quoi faire ?

  void saveInv() async {
    if (_scannedItems.length == 0) {
      Fluttertoast.showToast(
          msg: "Impossible d'enregistrer un inventaire vide",
          backgroundColor: Colors.red);
      return;
    }

    if (widget.invCode == null) {
      var ds = await UnigesService.dsGet("Inv");
      var code = await UnigesService.dsPostgetCode(ds) ?? "";
      _scannedItems.forEach((x) {
        x["Inv_Code"] = code;
      });
    }

    var _arrinvd = {"InvDC": _scannedItems};
    print(_arrinvd);

    if (await UnigesService.dsPost(_arrinvd)) {
      Fluttertoast.showToast(
          msg: "Inventaire enregistré avec succès",
          backgroundColor: Colors.green);
      Navigator.of(context).pop();
    } else {
      Fluttertoast.showToast(
          msg: "Enregistrement impossible", backgroundColor: Colors.red);
    }
  }

  void openCamera() async {
    if (!(await Permission.camera.request()).isGranted) {
      Fluttertoast.showToast(msg: "Permission caméra est nécessaire");
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
    );

    if (result != null) {
      onQrCodeScan(result);
    }
  }
}
