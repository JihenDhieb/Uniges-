import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uniges/services/uniges_service.dart';

class ListDoc extends StatefulWidget {
  dynamic ds;
  ListDoc(this.ds, {super.key});

  @override
  State<ListDoc> createState() => _ListDocState();
}

class _ListDocState extends State<ListDoc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(title: Text("Bon d'entrée")),
        floatingActionButton: FloatingActionButton(
            onPressed: () => _save(), child: Icon(Icons.check)),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${widget.ds?["Document"][0]["Doc_Type"]}",
                        style: TextStyle(fontSize: 25)),
                    SizedBox(height: 8),
                    Text(
                      "${widget.ds?["Document"][0]["Doc_Ref"]}",
                      style: const TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                    if (widget.ds["Document"][0]["Site_Code"] != null)
                      Text(
                        "Site : ${widget.ds["Document"][0]["Site_Code"]}",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    if (widget.ds["Document"][0]["Tiers_code"] != null)
                      Text(
                        "Tiers : ${widget.ds["Document"][0]["Tiers_code"]}",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      )
                  ],
                ),
              ),
              Expanded(
                  flex: 2,
                  child: ListView.builder(
                      itemCount: widget.ds["DocumentD"].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${widget.ds["DocumentD"][index]["DocD_Q"]} ${widget.ds["DocumentD"][index]["DocD_Unite"]}  x  ${widget.ds["DocumentD"][index]["Art_Des"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (widget.ds["DocumentD"][index]
                                              ["DocD_Car1"] !=
                                          null)
                                        Text(
                                          "${widget.ds["DocumentD"][index]["DocD_Car1"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      if (widget.ds["DocumentD"][index]
                                              ["DocD_Car2"] !=
                                          null)
                                        Text(
                                          "${widget.ds["DocumentD"][index]["DocD_Car2"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      if (widget.ds["DocumentD"][index]
                                              ["DocD_Car3"] !=
                                          null)
                                        Text(
                                          "${widget.ds["DocumentD"][index]["DocD_Car3"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      if (widget.ds["DocumentD"][index]
                                              ["DocD_Car4"] !=
                                          null)
                                        Text(
                                          "${widget.ds["DocumentD"][index]["DocD_Car4"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      if (widget.ds["DocumentD"][index]
                                              ["DocD_Car5"] !=
                                          null)
                                        Text(
                                          "${widget.ds["DocumentD"][index]["DocD_Car5"]}",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      })),
            ],
          ),
        )));
  }

  _save() async {
    print(widget.ds);
    try {
      await UnigesService.DocPost(widget.ds);
      Fluttertoast.showToast(
          msg: "Enregistrement effectué avec succès !",
          backgroundColor: Colors.green[800]);
      Navigator.of(context).pop();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}
