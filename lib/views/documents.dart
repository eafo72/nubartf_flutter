import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../dialogs/loading-dialog.dart';
import '../shared/buttons.dart';
import '../utils/url-launcher-utils.dart';
import '../widgets/menu_inferior_home.dart';
import 'login.dart';

import '../sqlhelper.dart';

class Documents extends StatefulWidget {
  static const String routeName = 'documents';

  Documents({Key? key}) : super(key: key);

  @override
  State<Documents> createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  bool loading = false;

  bool? _logged;

  int? _id_usuario;

  List<Map<String, dynamic>> _marcas = [];
  List _documentos = [];

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _logged = prefs.getBool('logged');

    await prefs.setString('last_nav_position', "documents");

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

    //objetivos de la marca
    final data = await SQLHelper.getAllMarcas();
    //print(data);
    _marcas = data;

    //creamos lista de documentos
    for (int i = 0; i < _marcas.length; i++) {
      final alldocs = _marcas[i]['documentos'];
      final combodocs = alldocs.split(",");
      for (int j = 0; j < combodocs.length; j++) {
        _documentos
            .add({"idmarca": _marcas[i]['marcaid'], "doc": combodocs[j]});
      }
    }

    setState(() {});
    print(_documentos);

    setLoading(false);
  }

  //LOADING
  setLoading(bool valor) {
    setState(() {
      loading = valor;
    });
  }

  @override
  void initState() {
    super.initState();
    cargarData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff111c43),
        iconTheme: IconThemeData(
          color: Color(0xff141F76),
          size: 40.0,
        ),
        elevation: 0,
        leading: Image(
          filterQuality: FilterQuality.high,
          image: AssetImage('assets/img/icon-rtf-color.png'),
        ),
        centerTitle: true,
        title: Text(
          "Documentos",
          style: TextStyle(color: Colors.white),
        ),
        toolbarHeight: 70,
        excludeHeaderSemantics: true,
        actions: [
          IconButton(
              //padding: EdgeInsets.only(right: 40.0),
              icon: Icon(
                Icons.arrow_circle_left_rounded,
                color: Color(0xFFc1ea13),
                size: 40.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
        automaticallyImplyLeading: false,
      ),
      //drawer: MenuWidget(),
      body: (loading == true)
          ? LoadingDialog()
          : ListView(
              children: [
                SizedBox(
                  height: 20.0,
                ),
                _marcas.length > 0
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _marcas.length,
                            itemBuilder: (context, index) {
                              var Mission = _marcas[index];
                              return Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.transparent,
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        "Empresa: " + Mission['nombremarca'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal)),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: _documentos.length,
                                            itemBuilder: (context, index) {
                                              var Doc = _documentos[index];
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  if (Mission['marcaid'] ==
                                                      Doc['idmarca']) ...[
                                                    GestureDetector(
                                                      onTap: () {
                                                        launchInBrowser(
                                                            Uri.parse(Urls
                                                                    .documents +
                                                                Doc['doc']));
                                                      },
                                                      child: Text(
                                                        Doc['doc'],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xFF379b29),
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                  ],
                                                ],
                                              );
                                            }),
                                      ],
                                    ),
                                  ));
                            }),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Color(0xFFEDEDED),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("No existen documentos"),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
      bottomNavigationBar: MenuInferiorHome(btn1: 1, btn2: 1, btn3: 1, btn4: 1),
    );
  }
}
