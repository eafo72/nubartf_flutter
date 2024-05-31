import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/loading-dialog.dart';
import '../shared/buttons.dart';
import '../views/login.dart';
import '../widgets/menu_inferior_home.dart';

import '../sqlhelper.dart';

import 'dbEntregables.dart';
import 'dbMisiones.dart';
import 'dbObjetivosMarca.dart';
import 'dbRolMaestro.dart';
import 'dbTiendas.dart';
import 'dbVerificacionMarcas.dart';

class DatabaseMenu extends StatefulWidget {
  static const String routeName = 'databasemenu';

  DatabaseMenu({Key? key}) : super(key: key);

  @override
  State<DatabaseMenu> createState() => _DatabaseMenuState();
}

class _DatabaseMenuState extends State<DatabaseMenu> {
  bool loading = false;

  bool? _logged;

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    _logged = prefs.getBool('logged');

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
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Color(0xff141F76),
          size: 40.0,
        ),
        elevation: 0,
        centerTitle: true,
        title: Container(
          width: 180,
          child: Image(
            filterQuality: FilterQuality.high,
            image: AssetImage('assets/img/rtf_logo_black.png'),
          ),
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
                      //Contactanos
                      Center(
                        child: Text("Bases de datos",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: FlatTextButton(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return DBEntregables();
                      });
                      Navigator.push(context, route);
                    },
                    edgeInsetsPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    color: Color(0xff111c43),
                    text: Text(
                      'Entregables',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: FlatTextButton(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return DBMisiones();
                      });
                      Navigator.push(context, route);
                    },
                    edgeInsetsPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    color: Color(0xff111c43),
                    text: Text(
                      'Misiones',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: FlatTextButton(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return DBObjetivosMarca();
                      });
                      Navigator.push(context, route);
                    },
                    edgeInsetsPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    color: Color(0xff111c43),
                    text: Text(
                      'Objetivos Marca',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: FlatTextButton(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return DBVerificacionMarcas();
                      });
                      Navigator.push(context, route);
                    },
                    edgeInsetsPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    color: Color(0xff111c43),
                    text: Text(
                      'Verificación Marca',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: FlatTextButton(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return DBRolMaestro();
                      });
                      Navigator.push(context, route);
                    },
                    edgeInsetsPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    color: Color(0xff111c43),
                    text: Text(
                      'Rol Maestro',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: FlatTextButton(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return DBTiendas();
                      });
                      Navigator.push(context, route);
                    },
                    edgeInsetsPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    color: Color(0xff111c43),
                    text: Text(
                      'Tiendas',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: MenuInferiorHome(btn1: 1, btn2: 1, btn3: 1, btn4: 1),
    );
  }
}
