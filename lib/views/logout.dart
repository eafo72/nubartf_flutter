import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class Logout extends StatefulWidget {
  static const String routeName = 'logout';
  Logout({Key? key}) : super(key: key);

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('id_usuario');
    await prefs.remove('nombre_usuario');
    await prefs.remove('direccion_usuario');
    await prefs.remove('foto_usuario');
    await prefs.setBool('logged', false);
    await prefs.setString('last_nav_position', "logout");

    setState(() {}); //para que actualize la info obtenida de sharedpreferences
    final route = MaterialPageRoute(builder: (context) {
      return Login();
    });
    Navigator.push(context, route);
  }

  @override
  void initState() {
    super.initState();
    signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
