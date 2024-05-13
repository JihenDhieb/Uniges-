import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';
import 'package:uniges/widgets/demandeScanQrWidget.dart';
import 'package:http/http.dart' as http;

class CollisageContainerHome extends StatefulWidget {
  const CollisageContainerHome({super.key});

  @override
  State<CollisageContainerHome> createState() => _CollisageContainerHomeState();
}

class _CollisageContainerHomeState extends State<CollisageContainerHome>
    with WidgetsBindingObserver {
  File? _image;

  bool _isInForeground = true;

  var _numContainer;

  List<dynamic> data = [];
  dynamic scanObject;
  dynamic payload;

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

  void setLoadingState(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  void onQrCodeScan(code) async {
    print(code);
    if (mounted && code != null && code != "") {
      (_numContainer == null) ? await getScanContainer(code) : addColis(code);
    }
  }

  String replaceEmptyString(var input) {
    if (input == null || input == "") {
      return "--";
    } else {
      return input.toString();
    }
  }

  Future<void> getScanContainer(String docNum) async {
    dynamic res = await UnigesService.dsGet('XConteneurE', param: [docNum]);
    dynamic dsEmpty = await UnigesService.dsGet('XConteneurE');

    setState(() {
      payload = res;

      scanObject = json.decode(json.encode(dsEmpty['XConteneurD'][0]));
      payload["XConteneurD"]
          .removeWhere((doc) => doc["ContD_Code"] == null && doc["id"] == null);

      _numContainer = docNum;
      payload["XConteneurE"][0]["Cont_Code"] = docNum;

      data = payload['XConteneurD'];
    });
  }

  Future<void> addColis(String QRCODE) async {
    if (scanObject != null && _numContainer != null) {
      dynamic _scanObject = json.decode(json.encode(scanObject));
      _scanObject['ContD_Code'] = QRCODE;
      _scanObject['Cont_Code'] = _numContainer;

      _scanObject['image'] = null;

      if (payload != null && payload['XConteneurD'] != null) {
        payload['XConteneurD'].add(_scanObject);
        print(payload);
        setState(() {
          data = payload['XConteneurD'];
        });

        await onBtnImageClick();
      } else {
        print('Payload or XConteneurD is null');
      }
    } else {
      print('ScanObject or _numContainer is null');
    }
  }

  Future<void> onBtnImageClick() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        data[data.length - 1]['image'] = File(pickedFile.path);
      });
    }
  }

  Widget itemStep() {
    return Container(
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Conteneur : $_numContainer",
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Scanner votre Colis ou ",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {},
                  icon: ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    onPressed: onBtnCameraClick,
                    label: Text("Camera"),
                  ),
                )
              ],
            ),
            Center(
              child: Text(
                "Liste des colis",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        Text(
                          data[index]['ContD_Code'],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        data[index]['image'] != null
                            ? Image.file(
                                data[index]['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : GestureDetector(
                                onTap: () {
                                  onBtnImageClick();
                                },
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colisage Conteneur'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 20),
            (_numContainer == null)
                ? DemandeScanQrCodewidget(
                    key: UniqueKey(),
                    onBtnCameraClick: onBtnCameraClick,
                    title: "Scan QR Code",
                    decription: "Scanner Votre Conteneur !",
                  )
                : itemStep(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Visibility(
        visible: _numContainer != null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 20),
            FloatingActionButton(
              heroTag: 'btn2',
              onPressed: () {
                valider(context);
              },
              child: Icon(Icons.check),
            ),
          ],
        ),
      ),
    );
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

    try {
      for (int i = 0; i < data.length; i++) {
        dynamic colis = data[i];
        if (colis['image'] == null) {
          Fluttertoast.showToast(
            msg: "Veuillez capturer une image pour tous les colis.",
            backgroundColor: Colors.red,
          );
          setState(() {
            isLoading = false;
          });
          Get.back();
          return;
        }
        if (colis['image'] != null) {
          File image = colis['image'];
          String imageBase64 = base64Encode(await image.readAsBytes());

          Map<String, dynamic> dsFiles = await UnigesService.dsGet("Files");
          String colisCode = colis['ContD_Code'];
          dsFiles["Files"][0]["File_Key"] =
              "${payload['XConteneurE'][0]['Cont_Code']}_$colisCode";
          dsFiles["Files"][0]["File_Content"] = imageBase64;
          dsFiles["Files"][0]["File_Date"] = DateTime.now().toIso8601String();
          dsFiles["Files"][0]["File_Extension"] = "png";
          dsFiles["Files"][0]["File_Class"] = "XConteneurE";

          if (await UnigesService.dsPostImage(dsFiles)) {
            print("Image envoyée avec succès !");

            setState(() {
              data[i].remove('image');
            });
          } else {
            print("Erreur lors de l'envoi de l'image !");
            setState(() {
              isLoading = false;
            });
            Get.back();
            return;
          }
        }
      }

      // Envoi du payload avec UnigesService.dsPost
      if (await UnigesService.dsPost(payload)) {
        Fluttertoast.showToast(
          msg: "Enregistrement avec succès",
          backgroundColor: Colors.lime,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Erreur d'enregistrement",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print("Erreur lors de l'enregistrement : $e");
      Fluttertoast.showToast(
        msg: "Erreur d'enregistrement",
        backgroundColor: Colors.red,
      );
    }

    setState(() {
      isLoading = false;
    });

    Get.back();
  }
}
