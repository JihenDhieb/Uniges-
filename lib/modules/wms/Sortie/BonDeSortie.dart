import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uniges/modules/wms/Sortie/scandoc.dart';
import 'package:uniges/services/uniges_service.dart';

class BonDeSortie extends StatefulWidget {
  const BonDeSortie({super.key});

  @override
  State<BonDeSortie> createState() => _BonDeSortieState();
}

class _BonDeSortieState extends State<BonDeSortie> with WidgetsBindingObserver {
  int _index = 2;
  StepperType _type = StepperType.vertical;
  List<String> items = [];

  List sites = [];

  TextEditingController controller = TextEditingController();

  List<dynamic> steps = [
    {"index": 0, "icon": Icons.person, "title": "Opératuer", "value": null},
    {"index": 1, "icon": Icons.fire_truck, "title": "Camion", "value": null},
    {"index": 2, "icon": Icons.person, "title": "Chauffeur", "value": null},
    {
      "index": 3,
      "icon": Icons.location_on,
      "title": "Site source",
      "value": null
    },
    {
      "index": 4,
      "icon": Icons.location_on,
      "title": "Site destination",
      "value": null
    },
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      onQRCodeScanned((await Clipboard.getData(Clipboard.kTextPlain))?.text);
    });

    loadSites();
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
        title: Text('Bon de sortie'),
        actions: [
          IconButton(onPressed: _save, icon: Icon(Icons.arrow_forward))
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.qr_code_2),
      // ),
      body: Flex(
          direction: Axis.vertical,
          children: steps
              .map((e) => Expanded(
                  flex: _index == (e["index"] as int) ? 3 : 1,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _index = e["index"];
                      });
                    },
                    child: Container(
                      color: _index == (e["index"] as int)
                          ? Colors.blue[200]
                          : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(e["icon"] as IconData),
                              SizedBox(width: 16),
                              Text(
                                e["title"] as String,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          SizedBox(height: 16),
                          Text((e[(e["index"] == 0 || e["index"] == 2)
                                  ? "value2"
                                  : "value"] ??
                              "-") as String),
                        ],
                      ),
                    ),
                  )))
              .toList()),
    );
  }

  void go(int index) {
    if (index == -1 && _index <= 0) {
      return;
    }

    if (index == 1 && _index >= steps.length - 1) {
      return;
    }
    setState(() {
      _index += index;
    });
  }

  void _save() {
    if (steps.where((e) => e["value"] == null).isNotEmpty) {
      Fluttertoast.showToast(msg: "Veuillez remplir tous les champs");
      return;
    }

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ScanDoc(steps.map((e) => e["value"]).toList())));
  }

  onQRCodeScanned(String? text2) async {
    if (text2 == null || text2.isEmpty) return;

    text2 = UnigesService.decodeQRCode(text2);

    print(text2);

    if (text2 == null) {
      Fluttertoast.showToast(msg: "Veuillez utiliser un QRCode officiel");
      return;
    }

    List text = text2.split(";");

    if (_index == 1 && (!text.last.contains("TU"))) {
      Fluttertoast.showToast(msg: "Camion non valide");
      return;
    }

    if ((_index == 3 || _index == 4) &&
        (text.first != "Site" ||
            sites.map((element) => element["Site_Code"]).contains(text.last) ==
                false)) {
      Fluttertoast.showToast(msg: "Site incorrecte");
      return;
    }

    if (_index == 0 || _index == 2) {
      List? perso = await UnigesService.tableRecherche(
          "API_GetPersoNomByMatricule",
          param: [text.last]);
      if (perso == null || perso.isEmpty) {
        Fluttertoast.showToast(
            msg:
                "Vérifier que la matricule est correcte et que vous êtes présent");
        return;
      }
      setState(() {
        steps[_index]["value2"] =
            perso[0]["Perso_Prenom"] + " " + perso[0]["Perso_Nom"];
      });
    }

    setState(() {
      steps[_index]["value"] = text.last;
      go(1);
    });
  }

  void loadSites() async {
    var _sites = await UnigesService.tableRecherche("sites");
    if (_sites == null) return;

    sites = _sites;
  }
}
