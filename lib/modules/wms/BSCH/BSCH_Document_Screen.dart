import 'dart:io';

import 'package:flutter/material.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uniges/main.dart';
import 'package:uniges/modules/wms/BSCH/BSCH_ScanPieces.dart';
import 'package:uniges/services/uniges_service.dart';
import 'package:uniges/widgets/QrCodeScanner.dart';
import 'package:uniges/widgets/demandeScanQrWidget.dart';

class BSCHDocScreen extends StatefulWidget {
  final String type;
  final String matricule;
  const BSCHDocScreen({super.key, required this.type, required this.matricule});

  @override
  State<BSCHDocScreen> createState() => _BSCHDocScreenState();
}

class _BSCHDocScreenState extends State<BSCHDocScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  String? Camion;
  String? Chauffeur;
  String? Site;
  List<dynamic>? _sites = [];

  @override
  void initState() {
    initMethodChannel();
    super.initState();
  }

  bool _isInForeground = true;

  initMethodChannel() {
    WidgetsBinding.instance.addObserver(this);
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      if (_isInForeground)
        onQrCodeScan((await Clipboard.getData(Clipboard.kTextPlain))!.text);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Document ${widget.type}"),
      ),
      body: SafeArea(
        child: Center(
            child: (Camion == null)
                ? ScanCamion()
                : (Chauffeur == null)
                    ? ScanChauffeur()
                    : (Site == null)
                        ? ScanSite()
                        : CircularProgressIndicator()),
      ),
    );
  }

  void onQrCodeScan(code) async {
    if (code == null || code == "") return;

    if (Camion == null) {
      onQrScanCamion(code);
    } else if (Chauffeur == null) {
      onQrScanChauffeur(code);
    }
  }

  void onQrScanCamion(truckCode) async {
    try {
      truckCode = UnigesService.decodeQRCode(truckCode);
      if (!truckCode.toUpperCase().contains("TU")) {
        Fluttertoast.showToast(
          msg: "Veuillez entrer un QRCode camion valide",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
        );
        return;
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Veuillez entrer un QRCode officiel",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
      return;
    }

    try {
      if (truckCode.contains(";")) truckCode = truckCode.split(";")[1];

      setState(() {
        Camion = truckCode;
      });
    } catch (e) {}
  }

  void onQrScanChauffeur(chauffeur) async {
    try {
      chauffeur = UnigesService.decodeQRCode(chauffeur)!.split(";")[1];
      GetSites();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Veuillez entrer un QRCode officiel",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
      return;
    }

    try {
      setState(() {
        Chauffeur = chauffeur;
      });
    } catch (e) {}
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

  void GetSites() async {
    try {
      _sites = await UnigesService.tableRecherche("API_BS_SitesDestination",
          param: [androidId]);
      setState(() {});
      print(_sites);

      if (_sites!.isEmpty) {
        Fluttertoast.showToast(msg: "Pas de destination trouvées");
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "problème de connection survenu ! " + e.toString());
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget ScanCamion() {
    return Center(
      child: DemandeScanQrCodewidget(
          key: UniqueKey(),
          onBtnCameraClick: onBtnCameraClick,
          title: "",
          decription: "Veillez scanner Code Camion"),
    );
  }

  Widget ScanChauffeur() {
    return Center(
      child: Column(
        children: [
          Text(Camion!),
          DemandeScanQrCodewidget(
              key: UniqueKey(),
              onBtnCameraClick: onBtnCameraClick,
              title: "",
              decription: "Veillez scanner Code Chauffeur"),
        ],
      ),
    );
  }

  Widget ScanSite() {
    return SafeArea(
      child: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chargement des destinations',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SpinKitRing(
                    color: Colors.blue,
                    size: 100,
                  ),
                ],
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var item in _sites!)
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(14),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                item["Site_Code"],
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          onPressed: () => _onSiteClicked(item["Site_Code"]),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  _onSiteClicked(siteCode) async {
    try {
      var req = await UnigesService.tableRecherche("API_PDAProfile",
          param: [androidId]);
      if (req == null || req.isEmpty) {
        Fluttertoast.showToast(
            msg: "L'ID " + androidId + " n'est pas configuré !",
            backgroundColor: Colors.red);
        return;
      }

      String current_site = req[0]["Site_Code"] ?? "";

      var res = (await UnigesService.tableRecherche("API_BlocageBS2",
          param: [siteCode, current_site, Chauffeur!, Camion!]));

      if (res!.isEmpty) {
        Fluttertoast.showToast(
            msg: "Erreur de connexion au serveur !",
            backgroundColor: Colors.red);
        return;
      }

      if (res[0]["Blocage"] == "true") {
        Fluttertoast.showToast(
            msg: res[0]["Message"], backgroundColor: Colors.red);
        return;
      }

      Site = siteCode;
      dynamic Doc = {
        "camion": Camion,
        "chauffeur": Chauffeur,
        "siteDestination": Site,
        "site": current_site,
        "operateur": widget.matricule,
        "type": widget.type
      };
      print(Doc);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BSCHScanPieces(document: Doc)));
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red);
      return;
    }
  }
}
