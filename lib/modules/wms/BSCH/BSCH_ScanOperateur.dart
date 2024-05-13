import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uniges/modules/wms/BSCH/BSCH_Document_Screen.dart';
import 'package:uniges/services/uniges_service.dart';

class BSCHScanperateur extends StatefulWidget {
  final String document;

  const BSCHScanperateur({super.key, required this.document});

  @override
  _S1OperateurState createState() => _S1OperateurState();
}

class _S1OperateurState extends State<BSCHScanperateur>
    with WidgetsBindingObserver {
  bool _isLoading = false;
  dynamic Matricule;

  @override
  void initState() {
    initMethodChannel();
    super.initState();
  }

  bool _isInForeground = true;

  initMethodChannel() {
    /*try {
      channel.setMethodCallHandler((call) {
        if (mounted) {
          onQrCodeScan(call.arguments);
        }
        return;
      });
    } catch (e) {}*/

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
      body: SafeArea(
        child: Center(
          child: _isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Verification de l'ID",
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
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person),
                    Text('Veuillez scanner votre matricule'),
                  ],
                ),
        ),
      ),
    );
  }

  void onQrCodeScan(userID) async {
    try {
      userID = UnigesService.decodeQRCode(userID)!.split(";")[1];
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Veuillez entrer un QRCode officiel",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
      return;
    }

    if (await login(userID)) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BSCHDocScreen(
            type: widget.document,
            matricule: Matricule,
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Veuillez entrer un code valide",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
      );
    }
  }

  Future<bool> login(String code) async {
    setState(() {
      _isLoading = true;
    });
    try {
      var res = await UnigesService.tableRecherche("API_GetPersoNomByMatricule",
          param: [code]);

      if (res!.isEmpty) {
        Fluttertoast.showToast(msg: "Ce numéro de matricule n'est pas valide");
        _isLoading = false;
      } else {
        Matricule = res.elementAt(0)["Perso_Matricule"];

        _isLoading = false;
        return true;
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "problème de connection survenu !");
      _isLoading = false;
    }
    setState(() {
      _isLoading = false;
    });
    return false;
  }
}
