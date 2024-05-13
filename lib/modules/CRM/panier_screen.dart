import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/CRM/crm_service.dart';
import 'package:uniges/services/uniges_service.dart';

class PanierScreen extends StatefulWidget {
  final dynamic client;

  const PanierScreen({super.key, this.client});
  @override
  State<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends State<PanierScreen> {
  final CRMService crmService = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 5),
              color: Colors.grey.shade300,
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        margin: EdgeInsets.all(6),
        child: Obx(
          () => ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: crmService.cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = crmService.cartItems[index];
              return ListTile(
                title: Text(cartItem["Art_Des"].toString()),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cartItem["Art_PV"]} DT '),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _onQteClick(cartItem),
                          child: Text(
                            'Quantite: ${cartItem["DocD_Q"]}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 10),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (cartItem["DocD_Q"] == 1) {
                                  crmService.cartItems.removeAt(index);
                                  return;
                                }
                                _updateQuantity(index, cartItem["DocD_Q"] - 1);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _updateQuantity(index, cartItem["DocD_Q"] + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: ${calculateTotal().toStringAsFixed(3)} DT'),
              ElevatedButton(
                onPressed: () {
                  Valider(context);
                },
                child: Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
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
            onPressed: onBtnValiderClick,
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> onBtnValiderClick() async {
    var _requestBody = {
      "Document": [
        {
          "Doc_Num": "",
          "Tiers_code": widget.client['Tiers_code'],
          "Doc_RS": widget.client['Tiers_RS'],
          "Doc_Type": "PCMD",
          "Site_Code": "SFX"
        }
      ],
      "DocumentD": crmService.cartItems
          .map((cartItem) => {...cartItem, "DocD_Id": ""})
          .toList()
    };
    print(_requestBody);
    if (await UnigesService.DocPost(_requestBody)) {
      Fluttertoast.showToast(
          msg: "Enregistrement avec succès", backgroundColor: Colors.lime);
      crmService.cartItems.clear();
      Get.close(3);
    } else {
      Fluttertoast.showToast(
          msg: "Erreur d'enregistrement", backgroundColor: Colors.red);
      Get.close(0);
    }
  }

  double calculateTotal() {
    double total = 0.0;
    for (var item in crmService.cartItems) {
      total += item["Art_PV"] * item["DocD_Q"];
    }
    return total;
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity > 0) {
      setState(() {
        crmService.cartItems[index]["DocD_Q"] = newQuantity;
      });
    }
  }

  _onQteClick(cartItem) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double nbCartons = 0.0, nbUnits = 1.0, nbVrac = 0.0;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Saisie quantité"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Nombre de colis"),
                    onChanged: (v) {
                      try {
                        nbCartons = double.parse(v);
                      } catch (e) {}
                      setState(() {});
                    },
                  ),
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(hintText: "Nombre de pièces par colis"),
                    onChanged: (v) {
                      try {
                        nbUnits = double.parse(v);
                      } catch (e) {}

                      setState(() {});
                    },
                  ),
                  TextFormField(
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(hintText: "Nombre de pièces séparées"),
                    onChanged: (v) {
                      try {
                        nbVrac = double.parse(v);
                      } catch (e) {}
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Qte = ${nbCartons * nbUnits + nbVrac}'),
                onPressed: () {
                  Navigator.of(context).pop(nbCartons * nbUnits + nbVrac);
                },
              ),
            ],
          );
        });
      },
    ).then((v) {
      setState(() {
        if (v == 0) {
          crmService.cartItems.remove(cartItem);
        } else {
          cartItem["DocD_Q"] = v;
        }
      });
    });
  }
}
