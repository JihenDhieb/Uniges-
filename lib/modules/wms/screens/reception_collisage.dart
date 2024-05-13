import 'package:flutter/material.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';
import 'package:uniges/widgets/demandeScanQrWidget.dart';

class ReceptionCollisage extends StatefulWidget {
  const ReceptionCollisage({super.key});

  @override
  _ReceptionCollisageState createState() => _ReceptionCollisageState();
}

class _ReceptionCollisageState extends State<ReceptionCollisage>
    with WidgetsBindingObserver {
  bool _isInForeground = true;
  bool _isItem = false;
  dynamic payload;
  var _numDoc;
  TextEditingController codeInterneController = TextEditingController();

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

  get documentLoaded => (payload != null &&
      payload.containsKey("DocumentS") &&
      payload["DocumentS"][0]["Sto_Id"] != null);

  @override
  void initState() {
    initMethodChannel();
    super.initState();
  }

  void _onCameraTap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
    );

    if (result != null) {
      onQrCodeScan(result);
    }
  }

  void _showItemDialog(Map<String, dynamic> itemData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez scanner le code interne !'),
            Text(
              "Code fournisseur : ${itemData["xRefExterne"]}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextFieldItem(codeInterneController, "code interne"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _validateItem(itemData),
            child: const Text('Valider'),
          ),
          TextButton(
            onPressed: () => _cancelItem(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _validateItem(Map<String, dynamic> itemData) {
    final itemLot = codeInterneController.text;

    if (!(payload["DocumentS"] as List)
        .map((e) => e["Sto_Lot"])
        .contains(itemLot)) {
      setState(() {
        _isItem = false;
        itemData["Sto_Lot"] = itemLot;
        codeInterneController.text = "";
        Navigator.of(context).pop(true);
      });
    } else {
      Fluttertoast.showToast(
        msg: "Un colis portant le même nom existe déjà",
      );
    }
  }

  void _cancelItem() {
    setState(() {
      codeInterneController.text = "";
    });
    Navigator.of(context).pop(false);
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
            child: const Text('retour'),
          ),
          TextButton(
            onPressed: () async {
              if (await UnigesService.dsPost(payload)) {
                Fluttertoast.showToast(
                    msg: "Enregistrement avec succès",
                    backgroundColor: Colors.lime);
                Get.back();
              } else {
                Fluttertoast.showToast(
                    msg: "Erreur d'enregistrement",
                    backgroundColor: Colors.red);
              }
              Get.back();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void onQrCodeScan(code) async {
    if (mounted) {
      if (_isItem) {
        setState(() {
          codeInterneController.text = code.toString();
        });
      } else {
        if (payload == null || payload["DocumentS"][0]["Sto_Id"] == null)
          await getData(code);
      }
    }
  }

  getData(docNum) async {
    var res =
        await UnigesService.dsGet("WMS_ReceptionColisage", param: [docNum]);
    if (res == null || res["DocumentS"][0]["Sto_Id"] == null) {
      Fluttertoast.showToast(
          msg: "Impossible de trouver le bon de colisage  $docNum");
      return;
    }
    setState(() {
      payload = res;
      _numDoc = docNum;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reception Colisage'),
      ),
      body: (documentLoaded)
          ? itemStep()
          : DemandeScanQrCodewidget(
              key: UniqueKey(),
              onBtnCameraClick: _onCameraTap,
              title: "Scan QR Code",
              decription: "Scanner Votre Bon de Colisage !",
            ),
      floatingActionButton: Visibility(
        visible: (documentLoaded),
        child: FloatingActionButton(
          onPressed: () {
            valider(context);
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  Widget itemStep() {
    return Column(
      children: [
        Text(
          "Numero : $_numDoc",
          style: const TextStyle(fontSize: 20),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: payload["DocumentS"].length,
            itemBuilder: (context, index) {
              return _buildItemCard(payload["DocumentS"][index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> itemData) {
    final stoLot = itemData["Sto_Lot"] ?? "";
    final cardColor = (stoLot != null && stoLot.isNotEmpty && stoLot != "")
        ? Colors.lime[400]
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        color: cardColor,
        child: InkWell(
          onTap: () {
            _isItem = true;
            _showItemDialog(itemData);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildItemRow(
                  UnigesService.replaceEmptyString(itemData["Art_Code"]),
                  UnigesService.replaceEmptyString(itemData["xRefFournisseur"]),
                  UnigesService.replaceEmptyString(itemData["Sto_Q"]),
                  stoLot,
                  UnigesService.replaceEmptyString(itemData["Sto_Variante1"]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(
    String artCode,
    String xRefFournisseur,
    String stoQ,
    String stoLot,
    String stoVariante1,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              artCode,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 0, 0, 0),
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              xRefFournisseur,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              stoVariante1,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              stoQ,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 0, 0, 0),
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              stoLot,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextFieldItem(
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
      ),
    );
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
}
