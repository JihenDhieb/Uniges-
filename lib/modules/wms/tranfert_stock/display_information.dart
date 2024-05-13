import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
//import 'package:uniges/services/ui_service.dart';
import 'package:uniges/services/uniges_service.dart';

import 'package:uniges/widgets/QrCodeScanner.dart';

class DisplayInformationScreen extends StatefulWidget {
  final dynamic itemData;

  const DisplayInformationScreen({Key? key, required this.itemData})
      : super(key: key);

  @override
  State<DisplayInformationScreen> createState() =>
      _DisplayInformationScreenState();
}

class _DisplayInformationScreenState extends State<DisplayInformationScreen>
    with WidgetsBindingObserver {
  bool _isSiteCodeScanne = false;
  String _siteCode = "";
  TextEditingController controller = TextEditingController();
  dynamic payload;
  var qteSaisi = "0";
  var qte;
  bool _isInForeground = true;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
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

  @override
  void initState() {
    controller.text = "0";
    getData();
    initMethodChannel();
    super.initState();
  }

  Widget buildVariableCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("code: ${widget.itemData["Art_Code"]}"),
                Text("Lot: ${widget.itemData["Sto_Lot"]}"),
              ],
            ),
            const SizedBox(height: 10.0),
            Text("Des: ${widget.itemData["Art_Des"]}"),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Site: ${widget.itemData["Site_Code"]}"),
                Text("Statut: ${widget.itemData["Sto_Statut"]}"),
              ],
            ),
            const SizedBox(height: 16.0),
            Text("QTE: ${widget.itemData["Sto_Q"]}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    qte = widget.itemData['Sto_Q'];
    return Scaffold(
      appBar: AppBar(title: const Text('Information')),
      body: (!_isSiteCodeScanne)
          ? Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 400, child: buildVariableCard()),
                    const Icon(
                      Icons.qr_code_scanner,
                      size: 40,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Scanner le code de la nouvelle adresse",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "OU",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QRCodeScannerScreen()),
                        );

                        if (result != null) {
                          onQrCodeScan(result);
                        }
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Ouvrir la caméra'),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                const SizedBox(
                  height: 18,
                ),
                Text(
                  "Article : ${widget.itemData['Art_Code']}",
                  style: const TextStyle(fontSize: 18),
                ),
                const Text(
                  "Veuiller saisir la quantité à transférer",
                  style: TextStyle(fontSize: 16),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: textFieldItem(controller, "Quantité"),
                ),
                Text("Quantité initiale : ${widget.itemData['Sto_Q']}"),
                Text(
                    "Reste : ${(double.parse(qte.toString()) - double.parse(qteSaisi)).toString()}")
              ],
            ),
      floatingActionButton: (_isSiteCodeScanne)
          ? FloatingActionButton.extended(
              onPressed: () {
                confirmation(context);
              },
              label: (!_isSiteCodeScanne)
                  ? const Text("Transfert")
                  : const Text("Valider"))
          : const Text(""),
    );
  }

  void onQrCodeScan(code) async {
    if (mounted) {
      if (_siteCode == "" && code != "") {
        setState(() {
          _siteCode = code;
          _isSiteCodeScanne = true;
        });
      }
    }
  }

  Widget textFieldItem(
    TextEditingController controller,
    String hintText,
  ) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              if (value != "") qteSaisi = value;
            });
          },
          controller: controller,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.withOpacity(0.6),
            ),
            border: InputBorder.none,
          ),
        ));
  }

  Future<dynamic> valider(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan'),
        content: Container(
          height: 200,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: (_isSiteCodeScanne)
                ? const Text('Continuer')
                : const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Future<dynamic> confirmation(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation !'),
        content: const SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text("Confirmation de tranfert !")],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              save();
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> getData() async {
    payload = await UnigesService.dsGet("changement_emp");
  }

  Future<void> save() async {
    //  UIService.showLoadingDialog(context);
    //fill StockMvt

    payload["StockMvt"][0]["StockMvtParam_Code"] = "CHANGEMP";
    payload["StockMvt"][0]["StockMvt_Date"] = DateTime.now().toIso8601String();
    payload["StockMvt"][0]["StockMvt_Libelle"] = "Changement Emplacement PDA";
    //fill StockMvtD

    //from TR
    payload["StockMvtD"][0]["Sto_Id"] = widget.itemData['Sto_Id'];
    payload["StockMvtD"][0]["Art_Code"] = widget.itemData['Art_Code'];
    payload["StockMvtD"][0]["Art_Des"] = widget.itemData['Art_Des'];
    payload["StockMvtD"][0]["Sto_Variante1"] = widget.itemData['Sto_Variante1'];
    payload["StockMvtD"][0]["Sto_Variante2"] = widget.itemData['Sto_Variante2'];
    payload["StockMvtD"][0]["Sto_Variante3"] = widget.itemData['Sto_Variante3'];
    payload["StockMvtD"][0]["Sto_Variante4"] = widget.itemData['Sto_Variante4'];
    payload["StockMvtD"][0]["Sto_Variante5"] = widget.itemData['Sto_Variante5'];
    payload["StockMvtD"][0]["Sto_Lot"] = widget.itemData['Sto_Lot'];
    payload["StockMvtD"][0]["Sto_Prix"] = widget.itemData['Sto_Prix'];
    payload["StockMvtD"][0]["Sto_Statut"] = widget.itemData['Sto_Statut'];
    payload["StockMvtD"][0]["Sto_Unit"] = widget.itemData['Art_Unite'];

    payload["StockMvtD"][0]["Sto_DateP"] = widget.itemData['Sto_DateP'];

    payload["StockMvtD"][0]["Sto_DateR"] = widget.itemData['Sto_DateR'];
    payload["StockMvtD"][0]["Site_Code"] = widget.itemData['Site_Code'];
    //origine
    payload["StockMvtD"][0]["Site_CodeOrigine"] = widget.itemData['Site_Code'];

    payload["StockMvtD"][0]["Sto_StatutOrigine"] =
        widget.itemData['Sto_Statut'];

    payload["StockMvtD"][0]["Sto_EmpOrigine"] = widget.itemData['Sto_Emp'];

    payload["StockMvtD"][0]["Sto_LotOrigine"] = widget.itemData['Sto_Lot'];

    payload["StockMvtD"][0]["Art_CodeOrigine"] = widget.itemData['Art_Code'];
    payload["StockMvtD"][0]["Sto_Variante1Origine"] =
        widget.itemData['Sto_Variante1'];

    payload["StockMvtD"][0]["Sto_Variante2Origine"] =
        widget.itemData['Sto_Variante2'];

    payload["StockMvtD"][0]["Sto_Variante3Origine"] =
        widget.itemData['Sto_Variante3'];

    payload["StockMvtD"][0]["Sto_Variante4Origine"] =
        widget.itemData['Sto_Variante4'];

    payload["StockMvtD"][0]["Sto_Variante5Origine"] =
        widget.itemData['Sto_Variante5'];

    //saisie
    payload["StockMvtD"][0]["Sto_Q"] = controller.text;
    payload["StockMvtD"][0]["Sto_Emp"] = _siteCode;

    if (await UnigesService.dsPost(payload)) {
      Fluttertoast.showToast(
          msg: "Enregistrement avec succès", backgroundColor: Colors.lime);
      Get.close(2);
    } else {
      Get.back();
      Get.back();
      Fluttertoast.showToast(
          msg: "Erreur d'enregistrement", backgroundColor: Colors.red);
    }
  }
}
