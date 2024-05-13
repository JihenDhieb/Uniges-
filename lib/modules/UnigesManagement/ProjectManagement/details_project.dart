import 'package:flutter/material.dart';
import 'package:uniges/modules/UnigesManagement/ProjectManagement/edit_project.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final String idProjet;
  final String titre;
  final String description;
  final String dateCreation;
  final String tiers;
  final String statut;
  final String dateEcheance;
  final String payant;

  ProjectDetailsScreen({
    required this.idProjet,
    required this.titre,
    required this.description,
    required this.dateCreation,
    required this.tiers,
    required this.statut,
    required this.dateEcheance,
    required this.payant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Projet'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProjectScreen(
                    titre: titre,
                    description: description,
                    tiers: tiers,
                    statut: statut,
                    dateEcheance: dateEcheance,
                    payant: payant,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 5),
                Text(
                  'ID du Projet: $idProjet',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.title, color: Color.fromARGB(95, 105, 87, 27)),
                SizedBox(width: 5),
                Text(
                  'Titre: $titre',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.description,
                    color: Color.fromARGB(255, 141, 54, 73)),
                SizedBox(width: 5),
                Text(
                  'Description: $description',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.date_range,
                    color: Color.fromARGB(255, 39, 140, 223)),
                SizedBox(width: 5),
                Text(
                  'Date de création: $dateCreation',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.person, color: Color.fromARGB(255, 148, 239, 30)),
                SizedBox(width: 5),
                Text(
                  'Tiers: $tiers',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.check_circle,
                    color: Color.fromARGB(255, 190, 54, 221)),
                SizedBox(width: 5),
                Text(
                  'Statut: $statut',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.event, color: Colors.blue),
                SizedBox(width: 5),
                Text(
                  'Date d\'échéance: $dateEcheance',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.monetization_on,
                    color: Color.fromARGB(255, 133, 133, 63)),
                SizedBox(width: 5),
                Text(
                  'Payant: $payant',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.update, color: Colors.red),
                    SizedBox(width: 5),
                    Text(
                      'Date de dernière mise à jour:',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
