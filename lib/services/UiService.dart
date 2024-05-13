import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTheme {
  static showErrorSnackBar(String message) {
    Get.showSnackbar(GetSnackBar(
      message: message,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      animationDuration: const Duration(milliseconds: 500),
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.red.shade700,
    ));
  }

  static showSuccessSnackBar(String message) {
    Get.showSnackbar(GetSnackBar(
      message: message,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      animationDuration: const Duration(milliseconds: 500),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green.shade700,
    ));
  }

  static Future<bool> showConfirmationDialog(String confirmationText,
      {required String okButtonText,
      required String noButtonText,
      bool enabledOkButton = true,
      bool enabledNoButton = true,
      bool okButtonGreen = false,
      bool okButtonRed = false}) async {
    return await Get.dialog(AlertDialog(
      content: Text(confirmationText),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        okButtonText == null
            ? Container()
            : MaterialButton(
                onPressed: enabledOkButton
                    ? () {
                        Get.back(result: true);
                      }
                    : null,
                child: Text(
                  okButtonText,
                  style: TextStyle(
                      color: okButtonGreen
                          ? Colors.green.shade700
                          : okButtonRed
                              ? Colors.red.shade500
                              : Colors.black),
                ),
              ),
        noButtonText == null
            ? Container()
            : MaterialButton(
                onPressed: enabledNoButton
                    ? () {
                        Get.back(result: false);
                      }
                    : null,
                child: Text(noButtonText),
              )
      ],
    ));
  }

  static showLoadingDialog({String loadingMessage = "Chargement en cours .."}) {
    Get.dialog(AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          Container(width: 20),
          Expanded(
              child: Text(
            loadingMessage,
          ))
        ],
      ),
    ));
  }

  static loader() {
    return const Center(child: CircularProgressIndicator.adaptive());
  }

  static errorComponent(Function() retryFunction,
      {String errorMessage = "Echec de connexion serveur"}) {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(
        errorMessage,
        textAlign: TextAlign.center,
      ),
      ElevatedButton(onPressed: retryFunction, child: const Text("Réessayer"))
    ]));
  }
}
