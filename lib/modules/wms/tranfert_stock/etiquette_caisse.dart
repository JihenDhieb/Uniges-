import 'package:flutter/material.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:uniges/services/uniges_service.dart';

import 'package:uniges/widgets/QrCodeScanner.dart';

class EtiquetteCaisse extends StatefulWidget {
  final String emplacement;

  const EtiquetteCaisse({Key? key, required this.emplacement})
      : super(key: key);

  @override
  _etiquetteCaisseState createState() => _etiquetteCaisseState();
}

class _etiquetteCaisseState extends State<EtiquetteCaisse>
    with WidgetsBindingObserver {
  bool _EtiquetteValid = false;

  bool _isInForeground = true;

  Map<String, dynamic> data = {};

  TextEditingController qteController = TextEditingController();
  var article;

  num qteSaisie = 0;

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
        onQrCodeScan((await Clipboard.getData(Clipboard.kTextPlain))!.text!);
      }
    });
  }

  @override
  void initState() {
    print("emp = " + widget.emplacement);
    initMethodChannel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emplacement vide'),
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: (!_EtiquetteValid) ? etiquetteScanView() : etiquette()),
      floatingActionButton: (_EtiquetteValid)
          ? FloatingActionButton.extended(
              onPressed: () {
                confirmation(context);
              },
              label: const Text("Valider"))
          : const Text(""),
    );
  }

  Widget etiquetteScanView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("0 article trouvé !",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 25),
          const Icon(
            Icons.qr_code_scanner,
            size: 120,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          const SizedBox(height: 10),
          const Text(
            'Scanner le QR Code Etiquette Caisse De Groupage.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          const Text(
            "OU",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
              );

              if (result != null) {
                onQrCodeScan(result);
              }
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('ouvrir Camera'),
          ),
        ],
      ),
    );
  }

  Widget etiquette() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("code: ${article["Art_Code"]}"),
                    Text("Lot: ${article["Sto_Lot"]}"),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text("Des: ${article["Art_Des"]}"),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Site: ${article["Site_Code"]}"),
                    Text("Statut: ${article["Sto_Statut"]}"),
                  ],
                ),
              ],
            ),
          ),
        ),
        Text("Quantité initiale : ${article['Sto_Q']}"),
        Container(
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
                  qteSaisie = num.tryParse(value) ?? qteSaisie;
                });
              },
              controller: qteController,
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 16.0),
                hintText: "Quantité",
                hintStyle: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey.withOpacity(0.6),
                ),
                border: InputBorder.none,
              ),
            )),
        Text(
            "Quantité restante : ${num.parse(article["Sto_Q"].toString()) - qteSaisie}"),
      ],
    );
  }

  void onQrCodeScan(String code) async {
    if (!_EtiquetteValid) {
      if (mounted) {
        var _res = await UnigesService.tableRecherche("API_WMS_TRS_CarInfo",
            param: [code, widget.emplacement]);

        if (_res == null) return;

        if (_res.isNotEmpty) {
          setState(() {
            article = _res.first;
            _EtiquetteValid = true;
          });
        } else {
          Fluttertoast.showToast(msg: "Qr Code non valide");
        }
      }
    }
  }

  Future<void> save() async {
    dynamic payload = await UnigesService.dsGet("changement_emp");
    //fill StockMvt
    payload["StockMvt"][0]["StockMvtParam_Code"] = "CHANGEMP";
    payload["StockMvt"][0]["StockMvt_Date"] = DateTime.now().toIso8601String();
    payload["StockMvt"][0]["StockMvt_Libelle"] = "Changement Emplacement PDA";
    //fill StockMvtD

    //from TR
    payload["StockMvtD"][0]["Sto_Id"] = article['Sto_Id'];
    payload["StockMvtD"][0]["Art_Code"] = article['Art_Code'];
    payload["StockMvtD"][0]["Art_Des"] = article['Art_Des'];
    payload["StockMvtD"][0]["Sto_Variante1"] = article['Sto_Variante1'];
    payload["StockMvtD"][0]["Sto_Variante2"] = article['Sto_Variante2'];
    payload["StockMvtD"][0]["Sto_Variante3"] = article['Sto_Variante3'];
    payload["StockMvtD"][0]["Sto_Variante4"] = article['Sto_Variante4'];
    payload["StockMvtD"][0]["Sto_Variante5"] = article['Sto_Variante5'];
    payload["StockMvtD"][0]["Sto_Lot"] = article['Sto_Lot'];
    payload["StockMvtD"][0]["Sto_Prix"] = article['Sto_Prix'];
    payload["StockMvtD"][0]["Sto_Statut"] = article['Sto_Statut'];
    payload["StockMvtD"][0]["Sto_Unit"] = article['Art_Unite'];

    payload["StockMvtD"][0]["Sto_DateP"] = article['Sto_DateP'];

    payload["StockMvtD"][0]["Sto_DateR"] = article['Sto_DateR'];
    payload["StockMvtD"][0]["Site_Code"] = article['Site_Code'];
    //origine
    payload["StockMvtD"][0]["Site_CodeOrigine"] = article['Site_Code'];

    payload["StockMvtD"][0]["Sto_StatutOrigine"] = article['Sto_Statut'];

    payload["StockMvtD"][0]["Sto_EmpOrigine"] = article['Sto_Emp'];

    payload["StockMvtD"][0]["Sto_LotOrigine"] = article['Sto_Lot'];

    payload["StockMvtD"][0]["Art_CodeOrigine"] = article['Art_Code'];
    payload["StockMvtD"][0]["Sto_Variante1Origine"] = article['Sto_Variante1'];

    payload["StockMvtD"][0]["Sto_Variante2Origine"] = article['Sto_Variante2'];

    payload["StockMvtD"][0]["Sto_Variante3Origine"] = article['Sto_Variante3'];

    payload["StockMvtD"][0]["Sto_Variante4Origine"] = article['Sto_Variante4'];

    payload["StockMvtD"][0]["Sto_Variante5Origine"] = article['Sto_Variante5'];

    //saisie
    payload["StockMvtD"][0]["Sto_Q"] = qteController.text;
    payload["StockMvtD"][0]["Sto_Emp"] = widget.emplacement;

    if (await UnigesService.dsPost(payload)) {
      Fluttertoast.showToast(
          msg: "Enregistrement avec succès", backgroundColor: Colors.lime);
      Get.close(2);
    } else {
      Get.back();
      Fluttertoast.showToast(
          msg: "Erreur d'enregistrement", backgroundColor: Colors.red);
    }
  }

  Future<dynamic> confirmation(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation !'),
        content: const SizedBox(
          height: 150,
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
            onPressed: () async => await save(),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
