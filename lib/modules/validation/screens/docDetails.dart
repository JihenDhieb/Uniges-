import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:uniges/services/uniges_service.dart';

class DocDetails extends StatefulWidget {
  String? docNum;
  String? docType;
  final VoidCallback callback;
  DocDetails(this.docNum, this.docType, {super.key, required this.callback});
  @override
  State<DocDetails> createState() => _DocDetailsState();
}

class _DocDetailsState extends State<DocDetails> {
  List<dynamic>? array;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docNum.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onBtnValiderClick(),
        child: const Icon(Icons.check, size: 30),
      ),
      body: FutureBuilder(
          future: Future.wait([
            getDetails(widget.docNum, widget.docType),
            getDetailsColumns(widget.docType)
          ]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List docD = [];
              try {
                docD = snapshot.data!.first!;
              } catch (e) {
                print(e);
                //Get.back();
              }

              return (docD.isEmpty)
                  ? const Center(child: Text("Aucun élement n'est trouvé"))
                  : ListView.builder(
                      itemCount: docD.length,
                      itemBuilder: (context, index) {
                        var obj = docD[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2.0),
                          child: Card(
                              child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                                children: (snapshot.data?[1] as List)
                                    .map((x) => Row(
                                          children: [
                                            Text(
                                              "${x["TableRD_Des"].toString()} :",
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                                child: Text(
                                                    obj[x["TableRD_Champs"]]
                                                        .toString())),
                                          ],
                                        ))
                                    .toList()),
                          )),
                        );
                      });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Future<List?> getDetails(docNum, docType) async {
    List<dynamic>? array;
    array = await (UnigesService.tableRecherche(
        "API_AppValidation_DetailDoc_$docType",
        param: [docNum]));
    return array;
  }

  Future<List?> getDetailsColumns(docType) async {
    var res = await UnigesService.getTRColumns(
        "API_AppValidation_DetailDoc_$docType");

    return res;
  }

  onBtnValiderClick() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const SizedBox(
          height: 40,
          child: Center(child: Text('confirmation de validation !')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => validerDoc(widget.docNum),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> validerDoc(docNum) async {
    showLoadingDialog();

    var res;

    try {
      res = await UnigesService.dsGet("documentValide", param: [docNum]);
      res["Document"][0]["Doc_Valide"] = 1;

      if (await UnigesService.dsPost(res)) {
        Fluttertoast.showToast(
          msg: "Document validé avec succès",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        widget.callback;
        Get.close(4);
        Get.toNamed("/validation");
      } else {
        Fluttertoast.showToast(
          msg:
              "Erreur de validation ! veuillez contacter l'administrateur système",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 231, 131, 131),
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Get.back(); // Close loading indicator
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Une erreur s'est produite. Veuillez réessayer plus tard.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(255, 231, 131, 131),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      Get.back();
    }
  }

  void showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            body: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SpinKitWave(
                        color: Colors.blue,
                        size: 40.0,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Chargement en cours...',
                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
