import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/CRM/crm_service.dart';

class DetailArticleScreen extends StatelessWidget {
  final dynamic article;

  DetailArticleScreen({required this.article});

  final TextEditingController quantiteController = TextEditingController(
    text: "1",
  );
  final CRMService crmService = Get.find();

  double get total =>
      double.parse(article['Art_PV'].toString()) *
      int.parse(quantiteController.text);

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    avatar = const CircleAvatar(
      child: Icon(Icons.emoji_objects),
      radius: 50,
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addToCart,
        label: Text("Ajouter Panier"),
        icon: Icon(Icons.production_quantity_limits_rounded),
      ),
      appBar: AppBar(
        title: Text(
          article['Art_Des'],
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(8),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                article['Art_Code'],
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              Divider(),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                article['Art_Des'],
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              Divider(),
              const Text(
                'Prix',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "${article['Art_PV'].toStringAsFixed(3)} DT",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              Divider(),
              const Text(
                'Quantité en Stock',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                article['Art_Stock'].toString(),
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 100,
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          quantiteController.text =
                              (int.parse(quantiteController.text) - 1)
                                  .toString();
                        },
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          size: 40,
                          color: Colors.red,
                        )),
                    Container(
                      width: 70,
                      child: GestureDetector(
                        onTap: () {
                          if (quantiteController.text.isNotEmpty) {
                            quantiteController.selection = TextSelection(
                                baseOffset: 0,
                                extentOffset: quantiteController.text.length);
                          }
                        },
                        child: TextField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                          keyboardType: TextInputType.number,
                          controller: quantiteController,
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          quantiteController.text =
                              (int.parse(quantiteController.text) + 1)
                                  .toString();
                        },
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 40,
                          color: Colors.green,
                        ))
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "",
                    style: TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _addToCart();
                    },
                    child: Text("Ajouter au panier"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    final int quantity = int.parse(quantiteController.text);
    if (quantity > 0) {
      // Check if the article already exists in the cart
      bool articleExists = false;
      for (dynamic cartItem in crmService.cartItems) {
        if (cartItem['Art_Code'] == article['Art_Code']) {
          // Article already exists, increment the quantity
          cartItem['DocD_Q'] += quantity;
          articleExists = true;
          break;
        }
      }

      // If the article doesn't exist, add it to the cart
      if (!articleExists) {
        crmService.cartItems.add({
          ...article,
          "DocD_Q": quantity,
        });
      }

      Fluttertoast.showToast(
          msg: "Article ajouté au panier", backgroundColor: Colors.green);
      Get.close(0);
    } else {
      Fluttertoast.showToast(
          msg: "La quantité doit être supérieure à zéro",
          backgroundColor: Colors.red);
    }
  }
}
