import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart'; //para definir orientacion x default
import 'package:flutter_localizations/flutter_localizations.dart';


import 'package:shared_preferences/shared_preferences.dart';

import 'dbviews/dbTiendas.dart';
import 'dialogs/loading-dialog.dart';

import 'views/home.dart';
import 'views/login.dart';
import 'views/logout.dart';
import 'views/shops.dart';
import 'views/shopDetail.dart';
import 'views/profile.dart';
import 'views/documents.dart';
import 'views/history.dart';
import 'views/credential.dart';
import 'views/program.dart';
import 'views/daydetails.dart';
import 'views/targets.dart';
import 'views/targetdetail.dart';
import 'views/travelMoney.dart';

import 'dbviews/databaseMenu.dart';
import 'dbviews/dbEntregables.dart';
import 'dbviews/dbMisiones.dart';
import 'dbviews/dbObjetivosMarca.dart';
import 'dbviews/dbVerificacionMarcas.dart';
import 'dbviews/dbRolMaestro.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //inicializamos firebase
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'nuba RTForms',
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: [
        const Locale('en', 'US'), // American English
        const Locale('es', 'MX'), // México
      ],
      theme: ThemeData(primarySwatch: Colors.grey,fontFamily: 'Montserrat'),
      //initialRoute: 'login',
      home: Root(),
      routes: {
        Home.routeName: (BuildContext context) => Home(),
        Login.routeName: (BuildContext context) => Login(),
        Logout.routeName: (BuildContext context) => Logout(),
        Shops.routeName: (BuildContext context) => Shops(),
        ShopDetail.routeName: (BuildContext context) => ShopDetail(),
        Profile.routeName: (BuildContext context) => Profile(),
        Documents.routeName: (BuildContext context) => Documents(),
        History.routeName: (BuildContext context) => History(),
        Credential.routeName: (BuildContext context) => Credential(),
        Program.routeName: (BuildContext context) => Program(),
        DayDetails.routeName: (BuildContext context) => DayDetails(),
        Targets.routeName: (BuildContext context) => Targets(),
        TargetDetail.routeName: (BuildContext context) => TargetDetail(),
        TravelMoney.routeName: (BuildContext context) => TravelMoney(),

        DatabaseMenu.routeName: (BuildContext context) => DatabaseMenu(),
        DBEntregables.routeName: (BuildContext context) => DBEntregables(),
        DBMisiones.routeName: (BuildContext context) => DBMisiones(),
        DBObjetivosMarca.routeName: (BuildContext context) => DBObjetivosMarca(),
        DBVerificacionMarcas.routeName: (BuildContext context) => DBVerificacionMarcas(),
        DBRolMaestro.routeName: (BuildContext context) => DBRolMaestro(),
        DBTiendas.routeName: (BuildContext context) => DBTiendas(),

      },
    );
  }
}

class Root extends StatefulWidget {
  Root({Key? key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

//clase que verifica si esta logueado para enviar a login o inicio
class _RootState extends State<Root> {
  bool loading = false;
  int? _id_usuario;
  String? _nombre_usuario;
  String? _direccion_usuario;
  String? _foto_usuario;
  bool? _logged;
  String? _last_nav_position;

  setLoading(bool valor) {
    setState(() {
      loading = valor;
    });
  }

  cargarPrefs() async {
    setLoading(true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _nombre_usuario = prefs.getString('nombre_usuario');
    _direccion_usuario = prefs.getString('direccion_usuario');
    _foto_usuario = prefs.getString('foto_usuario');
    _logged = prefs.getBool('logged');

    _last_nav_position = prefs.getString('last_nav_position');

    setState(() {});
    setLoading(
        false); //para que actualize la info obtenida de sharedpreferences
  }

  @override
  void initState() {
    super.initState();
    cargarPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return (loading == true)
        ? LoadingDialog()
        : _logged == true
            ? _last_nav_position == "targetDetail" ? TargetDetail()  : Home()
            : Login();
  }
}






