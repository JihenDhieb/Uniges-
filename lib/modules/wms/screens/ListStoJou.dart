import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ListStoJou extends StatefulWidget {
  String codeArt;
  String? lot;
  String? site;
  String? period;
  List<dynamic>? array;
  ListStoJou(this.codeArt, this.array);
  @override
  State<ListStoJou> createState() => _ListStoJouState();
}

class _ListStoJouState extends State<ListStoJou> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Mouvement de stock")),
        body: SafeArea(
          child: ListView.builder(
              itemCount: widget.array!.length,
              itemBuilder: (context, index) {
                var obj = widget.array![index];
                return Card(
                    child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CardTitle(obj),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(obj['StoJ_Date'].substring(0, 10),
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                                Text(obj['Art_Code'],
                                    style: TextStyle(fontSize: 18)),
                              ]),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (obj['StoJ_Q'] != "")
                                Text("Q : ${obj['StoJ_Q']}",
                                    style: TextStyle(fontSize: 16)),
                              SizedBox(height: 4),
                              if (obj['StoJ_Lot'] != "")
                                Text("Lot : ${obj['StoJ_Lot']}",
                                    style: TextStyle(fontSize: 18)),
                              SizedBox(height: 4),
                              if (obj['ArtS_Site'] != "")
                                Text("Site : ${obj['ArtS_Site']}",
                                    style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(" ${obj['StoJ_Variante1']}",
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text("${obj['StoJ_Variante2']}",
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text("${obj['StoJ_Variante3']}",
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text("${obj['StoJ_Variante4']}",
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text(" ${obj['StoJ_Variante5']}",
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                        ],
                      ),
                    ],
                  ),
                ));
              }),
        ));
  }

  Icon CardTitle(var obj) {
    return obj['StoJ_Nature'] == 'E'
        ? Icon(
            Icons.keyboard_double_arrow_right_rounded,
            color: Colors.green[300],
            size: 30,
          )
        : Icon(Icons.keyboard_double_arrow_left_rounded,
            color: Colors.red[400], size: 30);
  }
}
