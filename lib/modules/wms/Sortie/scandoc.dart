import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uniges/services/uniges_service.dart';

class ScanDoc extends StatefulWidget {
  dynamic ds;
  List docvalues;
  ScanDoc(this.docvalues, {super.key});

  @override
  State<ScanDoc> createState() => _ScanDocState();
}

class _ScanDocState extends State<ScanDoc> with WidgetsBindingObserver {
  var _docD = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
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
        floatingActionButton: FloatingActionButton(
            onPressed: () => _save(), child: Icon(Icons.check)),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text("${widget.ds?["Document"][0]["Doc_Type"]}",
                    //     style: TextStyle(fontSize: 25)),
                    // SizedBox(height: 8),
                    // Text(
                    //   "${widget.ds?["Document"][0]["Doc_Ref"]}",
                    //   style: const TextStyle(
                    //       fontStyle: FontStyle.italic, color: Colors.grey),
                    // ),
                    // if (widget.ds["Document"][0]["Site_Code"] != null)
                    //   Text(
                    //     "Site : ${widget.ds["Document"][0]["Site_Code"]}",
                    //     style: const TextStyle(fontStyle: FontStyle.italic),
                    //   ),
                    // if (widget.ds["Document"][0]["Tiers_code"] != null)
                    //   Text(
                    //     "Tiers : ${widget.ds["Document"][0]["Tiers_code"]}",
                    //     style: const TextStyle(fontStyle: FontStyle.italic),
                    //   )
                  ],
                ),
              ),
              Expanded(
                  flex: 2,
                  child: ListView.builder(
                      itemCount: _docD.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${_docD[index]["DocD_Q"]} ${_docD[index]["DocD_Unite"]}  x  ${_docD[index]["Art_Des"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (_docD[index]["DocD_Car1"] != null)
                                        Text(
                                          "${_docD[index]["DocD_Car1"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      if (_docD[index]["DocD_Car2"] != null)
                                        Text(
                                          "${_docD[index]["DocD_Car2"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      if (_docD[index]["DocD_Car3"] != null)
                                        Text(
                                          "${_docD[index]["DocD_Car3"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      if (_docD[index]["DocD_Car4"] != null)
                                        Text(
                                          "${_docD[index]["DocD_Car4"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      if (_docD[index]["DocD_Car5"] != null)
                                        Text(
                                          "${_docD[index]["DocD_Car5"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      })),
            ],
          ),
        )));
  }

  _save() async {
    print(widget.docvalues);

    var ds = {
      "Document": [
        {
          "Doc_Num": "",
          "Tiers_code": widget.docvalues[4], //site destination
          "Doc_Type": "BCONS",
          "Site_Code": widget.docvalues[3], // site source
          "Doc_Param3": widget.docvalues[2], //chauffeur
          "Doc_Param2": widget.docvalues[1], //camion,
          "Doc_Param4": widget.docvalues[0] //opérateur
        }
      ],
      "DocumentD": _docD
    };

    print(ds);

    try {
      await UnigesService.DocPost(ds);
      Fluttertoast.showToast(
          msg: "Enregistrement effectué avec succès !",
          backgroundColor: Colors.green[800]);
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void onQRCodeScanned(String? text) async {
    if (text == null) return;

    text = UnigesService.decodeQRCode(text);
    if (text == null) {
      Fluttertoast.showToast(msg: "Veuillez utiliser un QRCode officiel");
      return;
    }

    List? art = await UnigesService.tableRecherche("API_Stock_LoadArticle",
        param: [text]) as List?;

    if (art == null) {
      Fluttertoast.showToast(msg: "Erreur de connexion");
      return;
    }

    if (art.isEmpty) {
      Fluttertoast.showToast(
          msg: "L'article n'existe pas dans la base de données");
      return;
    }

    double? qte = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double v = 0.0;
        return AlertDialog(
          title: const Text("Choisir la quantité"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(art[0]["Art_Des"]),
              TextField(
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                    labelText: art[0]["DocD_Unite"], hintText: "Qté"),
                onChanged: (value) {
                  v = double.parse(value);
                },
              ),
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

    if (qte == null) {
      Fluttertoast.showToast(msg: "Veuillez choisir la quantité");
      return;
    }

    art[0]["DocD_Q"] = qte;
    art[0]["DocD_QC"] = qte;
    art[0]["DocD_Id"] = "";
    art[0]["DocD_Statut"] = "A";

    setState(() {
      _docD.add(art[0]);
    });
  }
}
