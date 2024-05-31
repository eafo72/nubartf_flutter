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
import 'targetDetail.dart';

class Targets extends StatefulWidget {
  static const String routeName = 'targets';

  Targets({Key? key}) : super(key: key);

  @override
  State<Targets> createState() => _TargetsState();
}

class _TargetsState extends State<Targets> {
  bool loading = false;

  bool? _logged;

  int? _id_usuario;
  int? _id_marca;
  int? _id_rol;
  int? _idot;
  String? _generalStatus;

  List<Map<String, dynamic>> _objetivos = [];

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _logged = prefs.getBool('logged');
    _id_marca = prefs.getInt('id_marca');
    _id_rol = prefs.getInt('id_rol');
    _idot = prefs.getInt('id_ot');
    _generalStatus = prefs.getString('generalStatus');

    await prefs.setString('last_nav_position', "targets");

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

    //objetivos de la tienda algunos titulos dicen marca pero son tienda x tiempo ya no se cambiaron
    final data = await SQLHelper.getObjetivosMarcaByRol(_id_rol, _id_marca);
    //print(data);
    _objetivos = data;

    setState(() {});

    setLoading(false);
  }

  _goTargetDetail(idobjetivomarca, idobjetivo, nombreobjetivo, firmaobjetivo,
      idtienda) async {
    if (_generalStatus == 'paused') {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              AttentionDialog(content: 'Estás en pausa, primero reanuda'));
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id_objetivo_marca', idobjetivomarca);
      await prefs.setInt('id_objetivo', idobjetivo);
      await prefs.setString('nombre_objetivo', nombreobjetivo);
      await prefs.setString('firma_objetivo', firmaobjetivo);
      await prefs.setInt('id_tienda', idtienda);

      final route = MaterialPageRoute(builder: (context) {
        return TargetDetail();
      });
      Navigator.push(context, route);
    }
  }

  _saveClient() async {
    //vemos si ya realizo todos los objetivos de la marca
    final _pendientes =
        await SQLHelper.checkObjetivosTerminados(_id_rol, _id_marca);
    int totalitems = _pendientes[0]['items'];
    if (totalitems > 0) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(
              content: 'Aún nos has terminado todos los objetivos'));
    } else {
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
                      _id_marca!,
                      _idot!,
                      fechaentregamision,
                      horaentregamision,
                      geoentregamision,
                      'Entregado');

                  //checamos si ya existe el registro en verificacion marcas
                  final data =
                      await SQLHelper.checkMarcaExistOnVM(_id_marca, _id_rol);
                  int totalitems = data[0]['items'];
                  if (totalitems > 0) {
                    await SQLHelper.updateStatusMarca(
                            _id_marca!, _id_rol!, 'Si')
                        .then((value) {
                      final route = MaterialPageRoute(builder: (context) {
                        return Home();
                      });
                      Navigator.push(context, route);
                    });
                  } else {
                    await SQLHelper.insertStatusMarca(
                            _id_marca!, _id_rol!, 'Si')
                        .then((value) {
                      final route = MaterialPageRoute(builder: (context) {
                        return Home();
                      });
                      Navigator.push(context, route);
                    });
                  }
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
          "Objetivos",
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
                  height: 30.0,
                ),
                _objetivos.length > 0
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _objetivos.length,
                            itemBuilder: (context, index) {
                              var Mission = _objetivos[index];
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
                                  child: Column(
                                    children: [
                                      /*
                                      FadeInImage.assetNetwork(
                                        width: double.infinity,
                                        //height: 190,
                                        fit: BoxFit.cover,
                                        placeholder: 'assets/img/loader.gif',
                                        placeholderFit: BoxFit.scaleDown,
                                        image:
                                            '${ServerInformation.IMAGES_ROOT}${Mission['imagenobjetivo']}',
                                      ),
                                      */
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(Mission['nombreobjetivo']),
                                          if (Mission['realizado'] == 1) ...[
                                            Icon(
                                              Icons.check,
                                              color: Color(0xff111c43),
                                              size: 40.0,
                                            ),
                                          ] else ...[
                                            IconButton(
                                              onPressed: () {
                                                _goTargetDetail(
                                                    Mission['id'],
                                                    Mission['idobjetivo'],
                                                    Mission['nombreobjetivo'],
                                                    Mission['firmaobjetivo'],
                                                    Mission['idtienda']);
                                              },
                                              icon: Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Color(0xFF26bf94),
                                                size: 40.0,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
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
                              Text("No existen objetivos"),
                            ],
                          ),
                        ),
                      ),
                SizedBox(height: 30),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: FlatTextButton(
                    onPressed: () {
                      _saveClient();
                    },
                    edgeInsetsPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    color: Color(0xff111c43),
                    text: Text(
                      'ENTREGAR OBJETIVOS',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
      bottomNavigationBar: MenuInferior(btn1: 1, btn2: 1, btn3: 1, btn4: 1),
    );
  }
}
