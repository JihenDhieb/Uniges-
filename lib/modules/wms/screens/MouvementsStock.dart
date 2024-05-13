// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:uniges/modules/wms/screens/ListStoJou.dart';
import 'package:uniges/services/uniges_service.dart';

class MouvementsStock extends StatefulWidget {
  const MouvementsStock({super.key});

  @override
  State<MouvementsStock> createState() => _MouvementsStockState();
}

class _MouvementsStockState extends State<MouvementsStock> {
  TextEditingController CodeArtTextController = TextEditingController();
  TextEditingController LotTextController = TextEditingController();
  TextEditingController SiteTextController = TextEditingController();
  TextEditingController PeriodTextController = TextEditingController();
  TextEditingController DateFin = TextEditingController();
  TextEditingController DateDebut = TextEditingController();
  List<dynamic>? array;
  DateTime dateD = DateTime(
      DateTime.now().year - 3, DateTime.now().month, DateTime.now().day);
  DateTime dateF = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
  @override
  void initState() {
    super.initState();

    DateDebut.text = DateFormat('yyyy-MM-dd').format(dateD).toString();

    DateFin.text = DateFormat('yyyy-MM-dd').format(dateF).toString();

    ClipboardListenerObj.listeners.clear();
    ClipboardListener.addListener(() async {
      onQRCodeScanned((await Clipboard.getData(Clipboard.kTextPlain))?.text);
    });
  }

  onQRCodeScanned(String? code) {
    if (code == null) return;

    code = UnigesService.decodeQRCode(code) ?? null;

    if (code == null) {
      return;
    }

    print(code);

    CodeArtTextController.text = code.split(";")[0];
    LotTextController.text = code.split(";")[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mouvements de stock'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Code Article',
                ),
                controller: CodeArtTextController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Lot',
                ),
                controller: LotTextController,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Site',
                ),
                controller: SiteTextController,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 145,
                    child: TextFormField(
                      controller: DateDebut,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          labelText: "Date début"),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dateD,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100));
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate!);
                        setState(() {
                          DateDebut.text = formattedDate;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 40),
                  SizedBox(
                    width: 145,
                    child: TextFormField(
                      controller: DateFin,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          labelText: "Date fin"),
                      readOnly: true,
                      onTap: () async {
                        final now = DateTime.now();
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: dateF,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100));
                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(pickedDate!);
                        setState(() {
                          DateFin.text = formattedDate;
                        });
                      },
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  List<dynamic>? arr;
                  arr = await getArray();

                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ListStoJou(
                                CodeArtTextController.text,
                                arr,
                              )));
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32))),
                child: const Text(
                  "Rechercher",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ));
  }

  Future<List?> getArray() async {
    String code = CodeArtTextController.text;
    if (CodeArtTextController.text == "") code = "";
    array = await UnigesService.tableRecherche("API_Mvt_Stock", param: [
      code,
      LotTextController.text,
      SiteTextController.text,
      DateDebut.text,
      DateFin.text
    ]);
    print(array.toString());
    return array;
  }
}
