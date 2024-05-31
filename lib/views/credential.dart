import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/constants.dart';
import '../dialogs/loading-dialog.dart';
import '../shared/buttons.dart';
import '../widgets/menu_inferior_home.dart';
import 'login.dart';

import '../sqlhelper.dart';

class Credential extends StatefulWidget {
  static const String routeName = 'credential';

  Credential({Key? key}) : super(key: key);

  @override
  State<Credential> createState() => _CredentialState();
}

class _CredentialState extends State<Credential> {
  bool loading = false;

  bool? _logged;

  int? _id_usuario;
  String? _foto_usuario;
  String? _nombre_usuario;
  String? _direccion_usuario;

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _foto_usuario = prefs.getString('foto_usuario');
    _nombre_usuario = prefs.getString('nombre_usuario');
    _direccion_usuario = prefs.getString('direccion_usuario');

    _logged = prefs.getBool('logged');

    await prefs.setString('last_nav_position', "credential");

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

    setState(() {});

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
          "Credencial",
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
                Container(
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Color(0xfffcfcfc),
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    //border: Border.all(color: Color(0xffa2a2a2)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        height: 300,
                        child: Stack(
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(0),
                                  bottomRight: Radius.circular(0),
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                                child: FadeInImage.assetNetwork(
                                  width: double.infinity,
                                  //height: 190,
                                  fit: BoxFit.cover,
                                  placeholder: 'assets/img/loader.gif',
                                  placeholderFit: BoxFit.scaleDown,
                                  image:
                                      '${ServerInformation.IMAGES_ROOT}/${_foto_usuario.toString()}',
                                )),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Center(
                        child: Text(
                          "Nombre: " + _nombre_usuario.toString(),
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Center(
                        child: Text(
                          "Dirección: " + _nombre_usuario.toString(),
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Center(
                        child: Text(
                          "ID: " + _id_usuario.toString(),
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Center(
                        child: QrImageView(
                          data: _nombre_usuario.toString() +
                              "ID:" +
                              _id_usuario.toString(),
                          version: QrVersions.auto,
                          size: 100.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: MenuInferiorHome(btn1: 1, btn2: 1, btn3: 1, btn4: 1),
    );
  }
}
