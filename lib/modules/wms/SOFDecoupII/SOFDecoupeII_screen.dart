import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uniges/main.dart';
import 'package:uniges/modules/wms/SOFDecoupII/SOFDecoupeII_AddSof_Screen.dart';
import 'package:uniges/services/uniges_service.dart';

class SOFDecoupeIIScreen extends StatefulWidget {
  const SOFDecoupeIIScreen({super.key});

  @override
  State<SOFDecoupeIIScreen> createState() => _SOFDecoupeIIScreenState();
}

class _SOFDecoupeIIScreenState extends State<SOFDecoupeIIScreen> {
  dynamic _sites = [];
  String? SiteCode;

  bool _isLoading = true;
  List<dynamic> arr = [];
  @override
  void initState() {
    GetSiteData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chargement des sites',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SpinKitRing(
                    color: Colors.blue,
                    size: 100,
                  ),
                ],
              )
            : (SiteCode == null)
                ? SiteStep()
                : OfStep(),
      ),
    ));
  }

  Widget SiteStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var item in _sites)
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      item["Site_Code"],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onPressed: () => _onSiteClicked(item["Site_Code"]),
              ),
          ],
        ),
      ),
    );
  }

  Widget OfStep() {
    return Container(
      child: ListView.builder(
        itemBuilder: _rowtemplate,
        itemCount: arr.length,
      ),
    );
  }

  Widget _rowtemplate(context, i) {
    var item = arr.elementAt(i);
    return InkWell(
      onTap: () {
        _navigateToDCDetails(item["OF_Num"]);
      },
      child: Card(
          child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [Text(item["OF_Num"])],
        ),
      )),
    );
  }

  void _navigateToDCDetails(item) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (c) => AddSofScreen(
              ofNum: item,
              siteCode: SiteCode!,
            )));
  }

  _onSiteClicked(siteCode) async {
    if (siteCode == null) return;
    setState(() {
      SiteCode = siteCode;
      GetOFData();
    });
  }

  void GetSiteData() async {
    try {
      _sites = await UnigesService.tableRecherche("sites");

      setState(() {});
      print(_sites);

      if (_sites.isEmpty) {
        Fluttertoast.showToast(msg: "Pas de sites trouvées");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "problème de connection survenu !");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void GetOFData() async {
    //showLoadingDialog(context, "Chargement des OF");
    var res = await UnigesService.tableRecherche("API_SOFCoupe_ListeDC",
        param: [androidId, SiteCode!]);
    print(res);
    //Navigator.of(context).pop();
    if (res!.length > 0) arr = res;

    setState(() {});
  }
}
