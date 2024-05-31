import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../dialogs/loading-dialog.dart';
import '../shared/buttons.dart';
import '../widgets/menu_inferior_home.dart';
import 'credential.dart';
import 'documents.dart';
import 'history.dart';
import 'login.dart';

import '../sqlhelper.dart';
import 'logout.dart';
import 'program.dart';

class Profile extends StatefulWidget {
  static const String routeName = 'profile';

  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool loading = false;

  bool? _logged;

  int? _id_usuario;
  String? _foto_usuario;

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _foto_usuario = prefs.getString('foto_usuario');
    _logged = prefs.getBool('logged');

    await prefs.setString('last_nav_position', "profile");

    setState(() {});
    print("Foto:" + _foto_usuario.toString());

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
          "Perfil",
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
          : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return Credential();
                      });
                      Navigator.push(context, route);
                    },
                    icon: Align(
                      alignment: Alignment.centerLeft,
                      child: Image(
                        image: AssetImage('assets/img/iconC.png'),
                        height: 24,
                        color: Color(0xFF26bf94),
                      ),
                    ),
                    label: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Credencial',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        //shape: MaterialStateProperty.all(StadiumBorder()),
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xff111c43)),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                        )),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return History();
                      });
                      Navigator.push(context, route);
                    },
                    icon: Align(
                      alignment: Alignment.centerLeft,
                      child: Image(
                        image: AssetImage('assets/img/iconA.png'),
                        height: 24,
                        color: Color(0xFF26bf94),
                      ),
                    ),
                    label: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Historial',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        //shape: MaterialStateProperty.all(StadiumBorder()),
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xff111c43)),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                        )),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return Program();
                      });
                      Navigator.push(context, route);
                    },
                    icon: Align(
                      alignment: Alignment.centerLeft,
                      child: Image(
                        image: AssetImage('assets/img/iconE.png'),
                        height: 24,
                        color: Color(0xFF26bf94),
                      ),
                    ),
                    label: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Programado',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        //shape: MaterialStateProperty.all(StadiumBorder()),
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xff111c43)),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                        )),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return Documents();
                      });
                      Navigator.push(context, route);
                    },
                    icon: Align(
                      alignment: Alignment.centerLeft,
                      child: Image(
                        image: AssetImage('assets/img/iconB.png'),
                        height: 24,
                        color: Color(0xFF26bf94),
                      ),
                    ),
                    label: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Documentos',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        //shape: MaterialStateProperty.all(StadiumBorder()),
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor:
                            MaterialStateProperty.all(Color(0xff111c43)),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                        )),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final route = MaterialPageRoute(builder: (context) {
                        return Logout();
                      });
                      Navigator.push(context, route);
                    },
                    icon: Align(
                      alignment: Alignment.centerLeft,
                      child: Image(
                        image: AssetImage('assets/img/iconD.png'),
                        height: 24,
                        color: Color(0xFF536485),
                      ),
                    ),
                    label: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side:
                                        BorderSide(color: Color(0xFF536485)))),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        //shape: MaterialStateProperty.all(StadiumBorder()),
                        elevation: MaterialStateProperty.all(0),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white),
                        padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                        )),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: MenuInferiorHome(btn1: 1, btn2: 1, btn3: 1, btn4: 1),
    );
  }
}
