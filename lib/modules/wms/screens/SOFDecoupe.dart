import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'package:uniges/services/uniges_service.dart';
// import 'package:uniges/widgets/demandeScanQrWidget.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';

class SOFDecoupe extends StatefulWidget {
  @override
  _SOFDecoupeState createState() => _SOFDecoupeState();
}

class _SOFDecoupeState extends State<SOFDecoupe> with WidgetsBindingObserver {
  final _box = GetStorage();
  bool _isOrdreDecoupScaned = false;
  bool _isBobineMPScaned = false;
  int _currentItem = -1;
  bool _isItem = false;
  bool _isInForeground = true;
  bool _isNumOrdreDecoupLoading = false;
  bool _isCodebobineMPLoading = false;
  bool _itemLoading = false;
  var _numOrdreDecoup = "";
  var _codebobineMP = "";
  var data;
  var defaultListSetting = [
    {
      "name": "WMS",
      "children": [
        {
          "name": "Réception",
          "children": [
            {"name": "Site_Code", "value": "SFX"},
            {"name": "OFSParam_Code", "value": "SOF"},
          ]
        }
      ]
    },
    {
      "name": "DASHBOARD",
      "children": [
        {
          "name": "GENERAL",
          "children": [
            {"name": "Chart_Color", "value": "red"},
          ]
        }
      ]
    }
  ];
  var settingList = [];
  List? ofsn;

  TextEditingController CodeLotController = TextEditingController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
  }

  initMethodChannel() {
    WidgetsBinding.instance.addObserver(this);
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      if (_isInForeground)
        onQrCodeScan((await Clipboard.getData(Clipboard.kTextPlain))!.text);
    });
  }

  @override
  void initState() {
    settingList = _box.read('settingList') ?? defaultListSetting;
    _isNumOrdreDecoupLoading = true;
    initMethodChannel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isOrdreDecoupScaned) {
          final confirmExit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmation'),
              content: const Text(
                  "Voulez vous sortir de l'écarn ?  \nTous les modifications vont être perdues"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Oui'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Non'),
                ),
              ],
            ),
          );
          return confirmExit ?? false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('SOF Découpe'),
        ),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: (_isBobineMPScaned)
                ? _ItemStep()
                : (_isOrdreDecoupScaned)
                    ? _BobineMpStep()
                    : _OrdredecoupeStep()),
        floatingActionButton: Visibility(
          visible: _isOrdreDecoupScaned,
          child: FloatingActionButton(
            onPressed: () {
              Valider(context);
            },
            child: const Icon(Icons.save),
          ),
        ),
      ),
    );
  }

  Widget _OrdredecoupeStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 120,
            color: Colors.red,
          ),
          const SizedBox(height: 20),
          const Text(
            'Scan QR Code',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Veuillez scanner Votre Ordre du découpe',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          const Text(
            "OR",
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
                print('Scanned code: $result');
                onQrCodeScan(result);
              }
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Open Camera'),
          ),
        ],
      ),
    );
  }

  Widget _BobineMpStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera,
            size: 72,
            color: Colors.red,
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            _numOrdreDecoup,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text("Veuillez scanner Votre bobine MP"),
          // DemandeScanQrCodewidget(
          //   key: UniqueKey(),
          //   onBtnCameraClick: onBtnCameraClick,
          //   title: "",
          //   decription: "Scanner un QR Code",
          // )
        ],
      ),
    );
  }

  // void onBtnCameraClick() async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => QRCodeScannerScreen()),
  //   );

  //   if (result != null) {
  //     onQrCodeScan(result);
  //   }
  // }

  Widget _ItemStep() {
    return Center(
      child: (_itemLoading)
          ? CircularProgressIndicator()
          : Column(
              children: [
                Text(
                  "$_numOrdreDecoup $_codebobineMP",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                (!_isOrdreDecoupScaned)
                    ? Text("Veuillez scanner ordre de coupe avant ça !")
                    : (data.isNotEmpty)
                        ? Container(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Card(
                                          color:
                                              (data[index]["OFD_Lot"] != "" &&
                                                      data[index]["OFD_Lot"] !=
                                                          null)
                                                  ? Colors.lime[400]
                                                  : Colors.white,
                                          child: InkWell(
                                            onTap: () {
                                              _currentItem = index;
                                              _isItem = true;
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title: Text(
                                                            'Confirmation'),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                'Veuiller scanner le code Lot !'),
                                                            Text(
                                                              "Code article : ${data[index]["Art_Code"]}",
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                              height: 16,
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              _isItem = false;
                                                              CodeLotController
                                                                  .text = "";
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(false);
                                                            },
                                                            child:
                                                                Text('Annuler'),
                                                          ),
                                                        ],
                                                      ));
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          "${data[index]["Art_Code"]}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          )),
                                                      if (data[index]
                                                              ["OFD_Lot"] !=
                                                          null)
                                                        Text(
                                                            "${data[index]["OFD_Lot"]}",
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(replaceEmptyString(
                                                          data[index]
                                                              ["Art_Car1"])),
                                                      Text(replaceEmptyString(
                                                          data[index]
                                                              ["Art_Car2"])),
                                                      Text(replaceEmptyString(
                                                          data[index]
                                                              ["Art_Car3"])),
                                                      Text(replaceEmptyString(
                                                          data[index]
                                                              ["Art_Car4"])),
                                                      Text(replaceEmptyString(
                                                          data[index]
                                                              ["Art_Car5"]))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          )));
                                }))
                        : Container()
              ],
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
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            contentPadding:
                EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.withOpacity(0.6),
            ),
            border: InputBorder.none,
          ),
        ));
  }

  Future<dynamic> Valider(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Container(
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
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: onBtnSaveClick,
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void onBtnSaveClick() async {
    var payload = data
        .map((e) => {
              "OFD_Id": e["OFD_Id"],
              "Art_Code": e["Art_Code"], //param
              "OFSD_DesArticle": e["OFD_DesArticle"],
              "OFSD_Q": e["OFD_Q"],
              "Art_Car1": e["Art_Car1"],
              "Art_Car2": e["Art_Car2"],
              "Art_Car3": e["Art_Car3"],
              "Art_Car4": e["Art_Car4"],
              "Art_Car5": e["Art_Car5"],
              "Art_Unite": e["OFD_Unite"], //param
              "OFSD_Lot": e["OFD_Lot"], //vide
              "Site_Code": getValue(settingList, "Site_Code"),
              "OFSD_Statut": "A",
            })
        .toList();
    print(payload);
    var body = {
      "ApiSOF": [
        {
          "OFSParam_Code": "SOF_PDA",
          "OF_Num": _numOrdreDecoup.toString(), //param
          "OFSD_Q": 0,
          "OFS_Q": 0
        }
      ],
      "OFSD": payload,
      "OFSN": ofsn!
    };
    print(body);

    if (await UnigesService.dsPost(body)) {
      Fluttertoast.showToast(
          msg: "Enregistrement avec succès", backgroundColor: Colors.lime);
      Get.back();
    } else {
      Fluttertoast.showToast(
          msg: "Erreur d'enregistrement", backgroundColor: Colors.red);
    }
    Get.back();
  }

  void onQrCodeScan(code) async {
    if (mounted) {
      if (_isNumOrdreDecoupLoading) {
        setState(() {
          _numOrdreDecoup = code.toString();
          _isOrdreDecoupScaned = true;
          _isNumOrdreDecoupLoading = false;
          _isCodebobineMPLoading = true;
        });
      } else if (_isCodebobineMPLoading) {
        await getDetails(_numOrdreDecoup, code);
        setState(() {
          _codebobineMP = code.toString();
          _itemLoading = false;
        });
      } else if (_isItem) {
        if (!(data as List).map((e) => e["OFD_Lot"]).contains(code))
          setState(() {
            _isItem = false;
            data[_currentItem]["OFD_Lot"] = code;

            Navigator.of(context).pop(true);

            CodeLotController.text = code.toString();
          });
        else {
          Fluttertoast.showToast(
              msg: "Un colis portant le même nom existe déjà",
              textColor: Colors.red);
        }
      }
    }
  }

  getDetails(_numOrdreDecoup, code) async {
    setState(() {
      _itemLoading = true;
    });
    var res = await (UnigesService.tableRecherche("API_Decoupe_OFD",
        param: [_numOrdreDecoup, code]));
    ofsn =
        await UnigesService.tableRecherche("API_Decoupe_OFSN", param: [code]);

    if (res == null || res == [] || res.isEmpty) {
      Fluttertoast.showToast(
          msg: "Impossible de trouver le bon du découpe $_numOrdreDecoup");

      return;
    } else if (ofsn == null || ofsn == []) {
      Fluttertoast.showToast(
          msg:
              "Impossible de trouver le bon du découpe $_numOrdreDecoup {OFSN}");
      return;
    }
    setState(() {
      data = res;
      _isNumOrdreDecoupLoading = false;
      _isCodebobineMPLoading = false;
      _isBobineMPScaned = true;
    });
  }

  String replaceEmptyString(var input) {
    if (input == null || input == "") {
      return "--";
    } else {
      return input.toString();
    }
  }

  String getValue(List<dynamic> list, String name) {
    for (var item in list) {
      if (item is Map<String, dynamic>) {
        if (item.containsKey("name") &&
            item.containsKey("value") &&
            item["name"] == name) {
          return item["value"];
        } else if (item.containsKey("children") &&
            item["children"] is List<dynamic>) {
          String nestedValue = getValue(item["children"], name);
          if (nestedValue != null) {
            return nestedValue;
          }
        }
      }
    }
    return "";
  }
}
