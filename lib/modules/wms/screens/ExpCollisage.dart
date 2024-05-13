import 'dart:async';
import 'dart:convert';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/home/login_page.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';
import 'package:uniges/widgets/demandeScanQrWidget.dart';

class ExpCollisage extends StatefulWidget {
  final int status;
  const ExpCollisage({super.key, required this.status});

  @override
  State<ExpCollisage> createState() => _ExpCollisageState();
}

class _ExpCollisageState extends State<ExpCollisage>
    with WidgetsBindingObserver {
  var _currentItem;
  bool _isInForeground = true;
  var _numDoc;
  List<dynamic> data = [];
  dynamic scanHistory;
  dynamic scanObject;
  dynamic payload;
  bool isQuantityAuto = false;
  bool isLoading = false;
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
      if (_numDoc == null) await getDoc(code);
      if (_numDoc != null) await getQuantity(code);
    }
  }

  String replaceEmptyString(var input) {
    if (input == null || input == "") {
      return "--";
    } else {
      return input.toString();
    }
  }

  getScanItems(String docNum) async {
    // var ds = await UnigesService.dsGet('DocSScan', param: [docNum]);
    dynamic res = await UnigesService.dsGet('DocSScan', param: [docNum]);
    dynamic dsEmpty = await UnigesService.dsGet('DocSScan');
    payload = res;
    scanHistory = json.decode(json.encode(payload['DocSScan']));
    scanObject = json.decode(json.encode(dsEmpty['DocSScan'][0]));

    payload["DocSScan"].removeWhere(
        (doc) => doc["Scan_Barre"] == null && doc["Art_Code"] == null);

    setState(() {});
  }

  getDoc(docNum) async {
    var res = await UnigesService.tableRecherche("SLotDocS", param: [docNum]);

    if (res == null || res.isEmpty) {
      Fluttertoast.showToast(
          msg: "Impossible de trouver le bon de colisage  $docNum");
      return;
    }

    setState(() {
      _numDoc = docNum;
      data = res;
    });

    await getScanItems(docNum);
  }

  getQuantity(QRCODE) async {
    double? selectedNumber;
    // List<String> values = QRCODE.split('*');

    //String replacedParam = QRCODE.replaceAll(';', '_');
    if (QRCODE == null || QRCODE == "") return;

    var itemInfo = await UnigesService.tableRecherche(
        "API_ExpColisage_ItemInfo",
        param: [QRCODE, isQuantityAuto.toString()]);

    if (itemInfo == null || itemInfo.isEmpty) {
      Fluttertoast.showToast(msg: "Code incorrect");
      return;
    }

    var checkList = payload['DocSScan']
        .where((item) => item['Scan_Barre'] == QRCODE)
        .toList();

    if (widget.status == 0) {
      // exp colisage
      if (checkList.length > 0) {
        Fluttertoast.showToast(
            msg: "Ce code à barre est déjà scannée", textColor: Colors.red);
        return;
      }
      // if (values.length >= 2) {
      String art = itemInfo[0]['Art_Code'].toString();
      String lot = itemInfo[0]['Sto_Lot'].toString();
      String Sto_Q = itemInfo[0]['Sto_Q'].toString();
      int Qte_PopUp = itemInfo[0]['Qte_PopUp'] ?? 0;

      int index = data.indexWhere(
          (item) => item['Sto_Lot'] == lot && item['Art_Code'] == art);

      if (index == -1) {
        Fluttertoast.showToast(
            msg: "Ce code à barre n'appartient à aucun article",
            textColor: Colors.red);
        return;
      }

      if (_currentItem != null &&
          _currentItem != index &&
          Get.arguments["Lot_Consecutif"] == "1") {
        Fluttertoast.showToast(
            msg: "vous devez terminer l'article actuel avant!");
        return;
      }
      if (Qte_PopUp == 1 || Qte_PopUp == 2) {
        selectedNumber = double.parse(Sto_Q);
      } else {
        selectedNumber = await showInputQuantityDialog(index, Sto_Q, Qte_PopUp);
      }

      var quantityScanned = payload['DocSScan']
          .where((item) =>
              item["Sto_Lot"] == data[index]["Sto_Lot"] &&
              item["Art_Code"] == data[index]["Art_Code"])
          .map<dynamic>((item) => item["Scan_Q"])
          .fold(0, (previousValue, element) => previousValue + element);

      if (selectedNumber != null && selectedNumber > 0) {
        double X = selectedNumber;
        if (quantityScanned + X > data[index]['Art_Q']) {
          Fluttertoast.showToast(
              msg: "Quantité demanée dépassée !", backgroundColor: Colors.red);
          return;
        }
        int scan_manual = 0;
        if (X != double.parse(Sto_Q)) scan_manual = 1;
        setState(() {
          //data[index]['Scan_Q'] += X;
          _currentItem = index;
        });
        if (quantityScanned + X == data[index]['Art_Q']) {
          setState(() {
            _currentItem = null;
          });
        }
        bool scanBarreExists = payload['DocSScan']
            .any((existingScan) => existingScan['Scan_Barre'] == QRCODE);
        if (!scanBarreExists) {
          dynamic _scanObject = json.decode(json.encode(scanObject));

          //remplir the scan object
          _scanObject['DocSScan_Id'] =
              DateTime.now().microsecondsSinceEpoch.toString();
          _scanObject['Doc_Num'] = _numDoc;
          _scanObject['Scan_Barre'] = QRCODE;
          _scanObject['Sto_Lot'] = lot;
          _scanObject['Art_Code'] = art;
          _scanObject['Scan_Q'] = X;
          _scanObject['Scan_Manuel'] = scan_manual;
          _scanObject['Scan_Emp'] = employee!.persoNom.toString();

          //push the scanObject in to payload
          payload['DocSScan'].add(_scanObject);
        } else {
          Fluttertoast.showToast(
              msg: "Ce code à barre est déjà scannée",
              backgroundColor: Colors.red);
          return;
        }
      }
    } else {
      //validation colisage
      int index =
          scanHistory.indexWhere((item) => item['Scan_Barre'] == QRCODE);

      if (index == -1) {
        Fluttertoast.showToast(
            msg: "Ce code à barre n'existe pas", textColor: Colors.red);
        return;
      }
      if (payload['DocSScan'][index]["Scan_Valide"] == 1) {
        Fluttertoast.showToast(
            msg: "Ce code à été déjà scanné en mode vérification",
            textColor: Colors.red);
        return;
      }
      setState(() {
        payload['DocSScan'][index]["Scan_Valide"] = 1;
      });
      Fluttertoast.showToast(msg: "Succès de lecture", textColor: Colors.green);
    }
    //   } else {
    //    Fluttertoast.showToast(msg: "invalid code a barre !");
    //  }
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

  Widget itemStep() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Numero : $_numDoc",
              style: const TextStyle(fontSize: 20),
            ),
            Row(
              children: [
                Text(
                  'qté auto :',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  width: 40,
                  child: FittedBox(
                    child: Switch(
                      value: isQuantityAuto,
                      onChanged: (value) {
                        setState(() {
                          isQuantityAuto = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
            //color: Colors.white,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  num _qteDemande;
                  num _qteScane;
                  num _qteRestante;
                  if (widget.status == 1) {
                    _qteDemande = payload['DocSScan']
                        .where((item) =>
                            item["Sto_Lot"] == data[index]["Sto_Lot"] &&
                            item["Art_Code"] == data[index]["Art_Code"])
                        .map<dynamic>((item) => item["Scan_Q"])
                        .fold(
                            0,
                            (previousValue, element) =>
                                previousValue + element);
                    _qteScane = payload['DocSScan']
                        .where((item) =>
                            item["Sto_Lot"] == data[index]["Sto_Lot"] &&
                            item["Art_Code"] == data[index]["Art_Code"] &&
                            item["Scan_Valide"] == 1)
                        .map<dynamic>((item) => item["Scan_Q"])
                        .fold(
                            0,
                            (previousValue, element) =>
                                previousValue + element);

                    _qteRestante = _qteDemande - _qteScane;
                  } else {
                    _qteDemande =
                        num.tryParse(data[index]["Art_Q"].toString()) ?? 0;
                    _qteScane = payload['DocSScan']
                        .where((item) =>
                            item["Sto_Lot"] == data[index]["Sto_Lot"] &&
                            item["Art_Code"] == data[index]["Art_Code"])
                        .map<dynamic>((item) => item["Scan_Q"])
                        .fold(
                            0,
                            (previousValue, element) =>
                                previousValue + element);
                    _qteRestante = _qteDemande - _qteScane;
                  }

                  return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Card(
                        elevation: (index == _currentItem) ? 8 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            width: 3,
                            color: Colors.transparent,
                          ),
                        ),
                        color: (_qteScane >= _qteDemande)
                            ? Colors.green
                            : (_qteScane > 0)
                                ? Colors.yellowAccent
                                : Colors.white,
                        child: InkWell(
                          onTap: () {
                            onCardArtTap(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${data[index]["Art_Code"]}",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${data[index]["Sto_Lot"]} ",
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      replaceEmptyString(
                                          data[index]["Sto_Emp"]),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Text(
                                  replaceEmptyString(data[index]["Art_Des"]),
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      " ${_qteScane.toStringAsFixed(0)} / ${_qteDemande.toStringAsFixed(0)}  ( ${(_qteRestante / num.parse(data[index]["Art_UCarton"].toString())).truncate().toStringAsFixed(0)} Car + ${(_qteRestante % num.parse(data[index]["Art_UCarton"].toString())).toStringAsFixed(0)} V) ",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ));
                })),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: (widget.status == 0)
            ? Text('expédition Colisage')
            : Text('validation Colisage'),
      ),
      floatingActionButton: Visibility(
        visible: _numDoc != null,
        child: FloatingActionButton(
          child: const Icon(Icons.check),
          onPressed: () {
            valider(context);
          },
        ),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: (_numDoc == null)
              ? DemandeScanQrCodewidget(
                  key: UniqueKey(),
                  onBtnCameraClick: onBtnCameraClick,
                  title: "Scan QR Code",
                  decription: "Scanner Votre Bon de Collisage !",
                )
              : itemStep()),
    );
  }

  void onCardArtTap(var index) {
    var filteredList;
    if (widget.status == 1) {
      filteredList = payload['DocSScan']
          .where((item) =>
              item['Art_Code'] == data[index]["Art_Code"] &&
              item['Sto_Lot'] == data[index]["Sto_Lot"] &&
              item["Scan_Valide"] == 1)
          .toList();
    } else {
      filteredList = payload['DocSScan']
          .where((item) =>
              item['Art_Code'] == data[index]["Art_Code"] &&
              item['Sto_Lot'] == data[index]["Sto_Lot"])
          .toList();
    }
    Get.dialog(
      AlertDialog(
        title: const Text('Element scanner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var item in filteredList)
              InkWell(
                onTap: () async {
                  bool itemSaved = false;
                  if (scanHistory != null && scanHistory != []) {
                    itemSaved = scanHistory.any((existingScan) =>
                        existingScan['DocSScan_Id'] == item['DocSScan_Id']);
                  }

                  if (!itemSaved) {
                    int index_item = payload['DocSScan'].indexWhere((element) =>
                        element['DocSScan_Id'] == item['DocSScan_Id']);

                    double? newQte =
                        await showInputQuantityDialog(index, item['Scan_Q'], 0);
                    payload['DocSScan'][index]['Scan_Q'] = newQte;
                    setState(() {});
                  }
                },
                child: Card(
                  //margin: const EdgeInsets.all(5),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Code: ${item['Scan_Barre']}'),
                            Text('Qte : ${item['Scan_Q']}')
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -8,
                        right: 1,
                        child: IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDeleteConfirmationDialog(item);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (filteredList.isEmpty) const Text('0 elements scanner '),
            if (filteredList.isNotEmpty) const Text('veuillez scanner .. '),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool checkIfDocIsDone() {
    bool result = true;
    data.forEach((e) {
      var _qteDemande = num.tryParse(e["Art_Q"].toString()) ?? 0;
      var _qteScane = payload['DocSScan']
          .where((item) =>
              item["Sto_Lot"] == e["Sto_Lot"] &&
              item["Art_Code"] == e["Art_Code"])
          .map<dynamic>((item) => item["Scan_Q"])
          .fold(0, (previousValue, element) => previousValue + element);

      var _qteRestante = _qteDemande - _qteScane;
      if (_qteRestante > 0) result = false;
    });

    return result;
  }

  void showDeleteConfirmationDialog(var item) {
    Get.defaultDialog(
      title: 'Confirmation',
      content: const Text('Voulez-vous vraiment supprimer cet élément ?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            removeFromList(item);
            Get.back();
            Get.back();
          },
          child: const Text('Supprimer'),
        ),
      ],
    );
  }

  void removeFromList(var item) {
    payload['DocSScan'].removeWhere(
        (element) => element['DocSScan_Id'] == item['DocSScan_Id']);
    setState(() {});
  }

  Future<double?> showInputQuantityDialog(int index, qte, Qte_PopUp) async {
    TextEditingController nbreController =
        TextEditingController(text: qte.toString());
    Completer<double?> completer = Completer<double?>();

    showDialog(
      context: Get.overlayContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Valider la quantité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${data[index]['Art_Code'].toString()} : ${data[index]['Sto_Lot'].toString()}",
                style: const TextStyle(fontSize: 18),
              ),
              TextFormField(
                readOnly: (Qte_PopUp == 3) ? true : false,
                keyboardType: TextInputType.number,
                controller: nbreController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                completer.complete(double.parse(nbreController.text));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  Future<dynamic> valider(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const SizedBox(
          height: 80,
          child: Column(
            children: [
              Text('confirmation enregistrement des données !'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: (isLoading) ? null : onBtnEnregistrerClick,
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void onBtnEnregistrerClick() async {
    setState(() {
      isLoading = true;
    });
    if (await UnigesService.dsPost(payload)) {
      Fluttertoast.showToast(
          msg: "Enregistrement avec succès", backgroundColor: Colors.lime);

      await getScanItems(_numDoc);
      bool docIsdone = checkIfDocIsDone();
      if (docIsdone) Get.back();
      setState(() {});
    } else {
      Fluttertoast.showToast(
          msg: "Erreur d'enregistrement", backgroundColor: Colors.red);
    }
    setState(() {
      isLoading = false;
    });
    Get.back();
  }
}
