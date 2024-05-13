import 'package:flutter/material.dart';
import 'package:uniges/services/uniges_service.dart';

class FormulairePage extends StatefulWidget {
  final String initialDuration;

  FormulairePage({required this.initialDuration});

  @override
  _FormulairePageState createState() => _FormulairePageState();
}

class _FormulairePageState extends State<FormulairePage> {
  String reportText = '';
  String duration = '';

  String selectedStatus = 'Faire';

  @override
  void initState() {
    super.initState();
    duration = widget.initialDuration;
  }

  void _save() async {
    try {
      String xStatut = selectedStatus == 'Faire' ? '2' : '0';

      Map<String, dynamic> existingData =
          await UnigesService.dsGet("MPRapport_Tache");
      print(existingData);

      Map<String, dynamic> firstDataEntry = existingData['MPRapport_Tache'][0];

      firstDataEntry['Rapport'] = reportText;
      firstDataEntry['Duree_realisation'] = duration;
      firstDataEntry['Xstatut'] = xStatut;

      await UnigesService.dsPost(existingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rapport enregistré avec succès!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'enregistrement du rapport: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajout Rapport"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  reportText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Texte du rapport',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              onChanged: (value) {
                setState(() {
                  duration = value;
                });
              },
              controller: TextEditingController(text: duration),
              decoration: InputDecoration(
                labelText: 'Durée manuelle',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  selectedStatus = newValue!;
                });
              },
              items: <String>['Faire', 'À faire'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
