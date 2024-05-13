import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uniges/services/uniges_service.dart';

class transactionDetails extends StatefulWidget {
  final dynamic DateD;
  final dynamic DateF;
  final dynamic nature;
  final dynamic Banque;
  final dynamic Type;

  final dynamic Societe;
  const transactionDetails(
      {super.key,
      required this.DateD,
      required this.DateF,
      required this.nature,
      required this.Banque,
      required this.Type,
      required this.Societe});

  @override
  State<transactionDetails> createState() => _transactionDetailsState();
}

class _transactionDetailsState extends State<transactionDetails> {
  dynamic data;
  @override
  void initState() {
    fetchData();
    super.initState();
  }

  Future<void> fetchData() async {
    data = await UnigesService.tableRecherche('apiEncFinD1', param: [
      widget.DateD,
      widget.DateF,
      widget.nature,
      widget.Banque,
      widget.Type,
      widget.Societe
    ]);
    setState(() {
      print(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Transactions Detail"),
        ),
        body: (data == null)
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "echéance :${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.DateD))}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text("Type: ${widget.Type}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        var entry = data[index];

                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Nature de Charge:',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      entry['nature de charge'],
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Détail: ',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      entry['type22'],
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${entry['nature1']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      '${entry['montant']} DT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ));
  }
}
