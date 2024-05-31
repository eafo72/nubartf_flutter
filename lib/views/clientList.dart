// lo quite del proyecto pq muestra la ruta empezando desde el cliente ej., hpmled

import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_checker/connectivity_checker.dart';

import '../config/constants.dart';
import '../dialogs/attention-dialog.dart';
import '../dialogs/loading-dialog.dart';
import '../shared/buttons.dart';
import '../widgets/menu_inferior.dart';
import 'home.dart';
import 'login.dart';

import '../sqlhelper.dart';
import 'targets.dart';

class ClientList extends StatefulWidget {
  static const String routeName = 'clientlist';

  ClientList({Key? key}) : super(key: key);

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  bool loading = false;

  bool? _logged;

  int? _id_usuario;
  int? _idot;
  int? _id_rol;
  String? _generalStatus;
  double? _distance;

  List<Map<String, dynamic>> _marcas = [];

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _logged = prefs.getBool('logged');
    _idot = prefs.getInt('id_ot');
    _id_rol = prefs.getInt('id_rol');
    _generalStatus = prefs.getString('generalStatus');
    _distance = prefs.getDouble('distance');

    await prefs.setString('last_nav_position', "clientList");

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

    //roles para hoy
    final data = await SQLHelper.getTodayRolesByROL(_id_rol);
    //print(data);
    _marcas = data;

    setState(() {});

    setLoading(false);
  }

  _goTargets(idmarca) async {
    if (_generalStatus == 'paused') {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              AttentionDialog(content: 'Estás en pausa, primero reanuda'));
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id_marca', idmarca);

      final route = MaterialPageRoute(builder: (context) {
        return Targets();
      });
      Navigator.push(context, route);
    }
  }

  _saveLocation(idmarca) async {
    if (_generalStatus == 'paused') {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              AttentionDialog(content: 'Estás en pausa, primero reanuda'));
    } else {
      //vemos si ya realizo todos los objetivos de la marca
      final _pendientes = await SQLHelper.checkMarcaTerminada(idmarca, _id_rol);
      int totalitems = _pendientes[0]['items'];
      if (totalitems > 0) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text("Atención"),
            content: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("¿Estás seguro?"),
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF111c43)),
                ),
                child: Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xff111c43)),
                ),
                child: Text(
                  "Sí",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (await ConnectivityWrapper.instance.isConnected) {
                    //guardar en tabla misiones fechaentregamision para que asi si ya tiene fecha entonces aparezca icono de subir info
                    DateTime dateToday = DateTime.now();
                    final fechaentregamision =
                        dateToday.toString().substring(0, 10);
                    final horaentregamision =
                        dateToday.toString().substring(11, 19);

                    //obtener permiso de ubicacion
                    Location location = Location();

                    bool _serviceEnabled;
                    PermissionStatus _permissionGranted;
                    LocationData _locationData;

                    _serviceEnabled = await location.serviceEnabled();
                    if (!_serviceEnabled) {
                      _serviceEnabled = await location.requestService();
                      if (!_serviceEnabled) {
                        setLoading(false);
                        return;
                      }
                    }

                    _permissionGranted = await location.hasPermission();
                    if (_permissionGranted == PermissionStatus.denied) {
                      _permissionGranted = await location.requestPermission();
                      if (_permissionGranted != PermissionStatus.granted) {
                        setLoading(false);
                        return;
                      }
                    }

                    //obtener ubicacion
                    _locationData = await location.getLocation();
                    //print(_locationData);

                    final geoentregamision = _locationData.latitude.toString() +
                        "," +
                        _locationData.longitude.toString();

                    await SQLHelper.updateMissionWhenFinish(
                        _id_rol!,
                        idmarca,
                        _idot!,
                        fechaentregamision,
                        horaentregamision,
                        geoentregamision,
                        'Entregado');

                    final route = MaterialPageRoute(builder: (context) {
                      return Home();
                    });
                    Navigator.push(context, route);
                  } else {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => AttentionDialog(
                            content:
                                'No hay conexión a internet para obtener tu ubicación'));
                  }
                },
              )
            ],
          ),
        );
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                AttentionDialog(content: 'Aún nos has terminado el cliente'));
      }
    }
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
                        child: Text("Clientes",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                      Text("Estás a " +
                          _distance.toString() +
                          " km de la tienda"),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
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
                              return Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (Mission['status'] == 'Si') ...[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(Mission['nombremarca'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal)),
                                              SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                          ),
                                          Icon(
                                            Icons.check,
                                            color: Color(0xff111c43),
                                            size: 40.0,
                                          ),
                                        ] else ...[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(Mission['nombremarca'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal)),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              //Text("Entregado")
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _goTargets(Mission['rolmarcaid']);
                                            },
                                            icon: Icon(
                                              Icons.play_circle_outline,
                                              color: Color(0xff111c43),
                                              size: 40.0,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  FlatTextButton(
                                    onPressed: () {
                                      _saveLocation(Mission['rolmarcaid']);
                                    },
                                    edgeInsetsPadding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 50),
                                    color: Color(0xff111c43),
                                    text: Text(
                                      'ENTREGAR UBICACIÓN',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                ],
                              );
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
                              Text("No existen clientes"),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
      bottomNavigationBar: MenuInferior(btn1: 1, btn2: 1, btn3: 1, btn4: 1),
    );
  }
}
