import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uniges/modules/CRM/article_list.dart';

class ficheClientScreen extends StatelessWidget {
  final dynamic contact;

  ficheClientScreen({required this.contact});

  @override
  Widget build(BuildContext context) {
    String avatarText = contact['Tiers_RS'].toUpperCase();
    Widget avatar;

    avatar = CircleAvatar(
      child: Text(avatarText),
      radius: 50,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Client Details')),
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: avatar),
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
                contact['Tiers_code'],
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Raison social',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                contact['Tiers_RS'],
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _navigateToEditContact(context, contact);
                    },
                    child: const Text('Ajouter Commande'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditContact(
      BuildContext context, Map<String, dynamic> contact) {
    Get.to(() => ListArticleScreen(client: contact));
  }

  void _deleteContact(BuildContext context, int contactId) {}
}
