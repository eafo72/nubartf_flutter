import 'dart:async';
import 'dart:convert';
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_checker/connectivity_checker.dart';

import 'package:location/location.dart';

import '../config/constants.dart';

import '../dialogs/attention-dialog.dart';
import '../dialogs/loading-dialog.dart';

import '../shared/buttons.dart';
import '../sqlhelper.dart';
import '../widgets/menu_inferior_home.dart';

import '../dbviews/databaseMenu.dart';
import 'login.dart';

import '../models/index.dart';
import 'shopDetail.dart';
import 'targets.dart';
import 'profile.dart';
import 'shops.dart';

class Home extends StatefulWidget {
  static const String routeName = 'home';

  Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool loading = false;

  bool? _keepSavingGPS;
  StreamSubscription<LocationData>? _locationSubscription;

  String? _mes;
  String? _mesNumero;
  String? _diaLetra;
  String? _hoyLetra;
  String? _hoyNumero;

  int? _id_usuario;
  String? _nombre_usuario;
  bool? _logged;

  double? _lastLat;
  double? _lastLong;

  List _db_rols = [];
  List _db_ot = [];
  List _db_objetivos = [];
  List _db_eo = [];
  List _db_elementos = [];
  List _db_tiendas = [];
  List _db_marcas = [];
  List _db_rols_unique = [];

  List<Map<String, dynamic>> _rolesHoy = [];
  List _entregables = [];

  //funcion para calcular distancia entre 2 coordenadas
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  Future checkin() async {
    //setLoading(true);

    /*
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

    //sincronizacion
    String url = '${ServerInformation.API_ROOT}/sincronizacion.php';
    var response = await Dio().post(
      url,
      options: Options(
        headers: {
          'Apikey': '${Secret.secretID}',
        },
      ),
      data: {
        'id_usuario': _id_usuario,
        'latlong': _locationData.latitude.toString() +
            "," +
            _locationData.longitude.toString()
      },
    );
    final data = response.data;
    //print(data);

    if (data['error'] == true) {
      setLoading(true);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(content: data['mensaje']));
    }
    */

    if (await ConnectivityWrapper.instance.isConnected) {
      //obtener todas las bases de datos
      String url1 =
          '${ServerInformation.API_ROOT}/exportar.php?id_usuario=${_id_usuario}';
      var response1 = await Dio().get(
        url1,
        options: Options(
          headers: {
            'Apikey': '${Secret.secretID}',
          },
        ),
      );
      final data1 = response1.data;
      //print(data1);

      if (data1[0]['error'] == true) {
        setLoading(false);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AttentionDialog(content: data1[0]['mensaje']));
      } else {
        //print(data1[0]['relacionOM']);
        //print(data1[0]['objetivos']);
        //print(data1[0]['relacionEO']);
        //print(data1[0]['elementosLlegada']);
        //print(data1[0]['rolMaestroMisiones']);
        //print(data1[0]['tienda']);
        //print(data1[0]['marcas']);
        //print(data1[0]['rolMaestroMisionesUnique']);

        //borramos contenido de las bd
        await SQLHelper.deleteInitialTables().then((value) async {
          //RELACION OT
          final listado1 = FullOT.fromJsonList(data1[0]['relacionOT']);

          _db_ot = listado1.itemsOT;
          setState(() {});

          //guardar en sqflite
          for (int i = 0; i < _db_ot.length; i++) {
            var item = _db_ot[i];
            await SQLHelper.createRelacionOT(item.relacion_ot_id,
                item.relacion_ot_tienda_id, item.relacion_ot_objetivo_id);
          }

          //OBJETIVOS
          final listado2 = FullObjetivos.fromJsonList(data1[0]['objetivos']);

          _db_objetivos = listado2.itemsObjetivos;
          setState(() {});

          //guardar en sqflite
          for (int i = 0; i < _db_objetivos.length; i++) {
            var item = _db_objetivos[i];
            await SQLHelper.createObjetivo(
                item.id,
                item.objetivo_id,
                item.nombre_objetivo,
                item.imagen_objetivo,
                item.tipo_objetivo,
                item.meta,
                item.entregados,
                item.firma);
          }

          //RELACION EO
          final listado3 = FullEO.fromJsonList(data1[0]['relacionEO']);

          _db_eo = listado3.itemsEO;
          setState(() {});

          //guardar en sqflite
          for (int i = 0; i < _db_eo.length; i++) {
            var item = _db_eo[i];
            await SQLHelper.createRelacionEO(
              item.relacioneoid,
              item.relacioneoobjetivoid,
              item.relacioneoelementosid,
              item.ordenaparicion,
            );
          }

          //ELEMENTOS LLEGADA
          final listado4 =
              FullElementos.fromJsonList(data1[0]['elementosLlegada']);

          _db_elementos = listado4.itemsElementos;
          setState(() {});

          //guardar en sqflite
          for (int i = 0; i < _db_elementos.length; i++) {
            var item = _db_elementos[i];
            await SQLHelper.createElementoLlegada(
                item.id,
                item.elemento_id,
                item.nombre_elemento,
                item.script_elemento,
                item.name,
                item.tipo_entrega);
          }

          //ROL MAESTRO MISIONES
          final listado5 =
              FullRols.fromJsonList(data1[0]['rolMaestroMisiones']);

          _db_rols = listado5.itemsRols;
          setState(() {});
          //print("roles"+_db_rols.length.toString());
          //guardar en sqflite
          for (int i = 0; i < _db_rols.length; i++) {
            var item = _db_rols[i];
            //print("solicitud:"+item.rol_maestro_id.toString());
            await SQLHelper.createRol(
                item.rol_maestro_id,
                item.rol_marca_id,
                item.rol_id_tienda,
                item.rol_id_orden_trabajo,
                item.fecha_hora_creacion_visita_rol,
                item.fecha_programada_visita_rol,
                item.hora_programada_visita_rol,
                item.usuario_id_creador_rol,
                item.colaborador_id_asignado_rol,
                item.fechayhorasubida,
                item.geosubida);
          }

          //TIENDA
          final listado6 = FullTienda.fromJsonList(data1[0]['tienda']);

          _db_tiendas = listado6.itemsTienda;
          setState(() {});

          //guardar en sqflite
          for (int i = 0; i < _db_tiendas.length; i++) {
            var item = _db_tiendas[i];
            await SQLHelper.createTienda(
                item.tienda_id,
                item.nombre_tienda,
                item.ubicacion_tienda,
                item.geo_tienda,
                item.encargado_tienda,
                item.documento,
                item.codigoqr,
                item.cadena_id_tienda);
          }

          //MARCAS
          final listado7 = FullMarcas.fromJsonList(data1[0]['marcas']);

          _db_marcas = listado7.itemsMarcas;
          setState(() {});

          //guardar en sqflite
          for (int i = 0; i < _db_marcas.length; i++) {
            var item = _db_marcas[i];
            await SQLHelper.createMarca(
                item.marca_id,
                item.mar_cliente_id,
                item.nombre_marca,
                item.descripcion_marca,
                item.tipo_marca,
                item.no_marca,
                item.documentos,
                item.incluye_inventario);
          }

          final parsearFecha = DateTime.now();
          switch (parsearFecha.month) {
            case 01:
              _mes = 'Enero';
              _mesNumero = '01';
              break;
            case 02:
              _mes = 'Febrero';
              _mesNumero = '02';
              break;
            case 03:
              _mes = 'Marzo';
              _mesNumero = '03';
              break;
            case 04:
              _mes = 'Abril';
              _mesNumero = '04';
              break;
            case 05:
              _mes = 'Mayo';
              _mesNumero = '05';
              break;
            case 06:
              _mes = 'Junio';
              _mesNumero = '06';
              break;
            case 07:
              _mes = 'Julio';
              _mesNumero = '07';
              break;
            case 08:
              _mes = 'Agosto';
              _mesNumero = '08';
              break;
            case 09:
              _mes = 'Septiembre';
              _mesNumero = '09';
              break;
            case 10:
              _mes = 'Octubre';
              _mesNumero = '10';
              break;
            case 11:
              _mes = 'Noviembre';
              _mesNumero = '11';
              break;
            case 12:
              _mes = 'Diciembre';
              _mesNumero = '12';
              break;
            default:
          }
          setState(() {});
          String _diaNumero = parsearFecha.day.toString().padLeft(2, '0');

          _hoyNumero = "${parsearFecha.year}-$_mesNumero-$_diaNumero";

          final data = await SQLHelper.getTodayRoles(_id_usuario, _hoyNumero);
          //print(data);
          _rolesHoy = data;
          //creamos tabla de seguimiento de objetivos apartir de los roles del dia
          for (int i = 0; i < _rolesHoy.length; i++) {
            int __idrol = _rolesHoy[i]['rolmaestroid'];
            int __idmarca = _rolesHoy[i]['rolmarcaid'];
            int __idtienda = _rolesHoy[i]['rolidtienda'];

            //buscamos cada objetivo
            final __objetivos =
                await SQLHelper.getRelationObjetivosTienda(__idtienda);
            for (int j = 0; j < __objetivos.length; j++) {
              int __idobjetivo = __objetivos[j]['relacionotobjetivoid'];

              //primero vemos si ya existe
              final _existe = await SQLHelper.getObjetivoMarcaExist(
                  __idrol, __idmarca, __idobjetivo);
              int totalitems = _existe[0]['items'];
              if (totalitems > 0) {
                //no hacemos nada
              } else {
                String nombreobjetivo = __objetivos[j]['nombreobjetivo'];
                String imagenobjetivo = __objetivos[j]['imagenobjetivo'];
                String firmaobjetivo = '';
                if (__objetivos[j]['firma'] == null ||
                    __objetivos[j]['firma'] == '') {
                  firmaobjetivo = 'No';
                } else {
                  firmaobjetivo = 'Si';
                }

                await SQLHelper.insertObjetivoMarca(
                    __idrol,
                    __idmarca,
                    __idtienda,
                    __idobjetivo,
                    nombreobjetivo,
                    imagenobjetivo,
                    firmaobjetivo);
              }
            }
          }
        });
      }
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              AttentionDialog(content: 'No hay conexión a internet'));
    }
  }

  Future cargarData() async {
    print("Cargando");
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _logged = prefs.getBool('logged');
    _keepSavingGPS = prefs.getBool('keepSavingGPS');

    await prefs.setString('last_nav_position', "home");

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

    //hacemos checkin
    checkin().then((value) async {
      final parsearFecha = DateTime.now();
      //final formatoFecha = DateFormat('MMMM dd, yyyy').format(parsearFecha);
      //print(parsearFecha.weekday);
      switch (parsearFecha.weekday) {
        case 1:
          _diaLetra = 'Lunes';
          break;
        case 2:
          _diaLetra = 'Martes';
          break;
        case 3:
          _diaLetra = 'Miércoles';
          break;
        case 4:
          _diaLetra = 'Jueves';
          break;
        case 5:
          _diaLetra = 'Viernes';
          break;
        case 6:
          _diaLetra = 'Sábado';
          break;
        case 7:
          _diaLetra = 'Domingo';
          break;
      }

      switch (parsearFecha.month) {
        case 01:
          _mes = 'Enero';
          _mesNumero = '01';
          break;
        case 02:
          _mes = 'Febrero';
          _mesNumero = '02';
          break;
        case 03:
          _mes = 'Marzo';
          _mesNumero = '03';
          break;
        case 04:
          _mes = 'Abril';
          _mesNumero = '04';
          break;
        case 05:
          _mes = 'Mayo';
          _mesNumero = '05';
          break;
        case 06:
          _mes = 'Junio';
          _mesNumero = '06';
          break;
        case 07:
          _mes = 'Julio';
          _mesNumero = '07';
          break;
        case 08:
          _mes = 'Agosto';
          _mesNumero = '08';
          break;
        case 09:
          _mes = 'Septiembre';
          _mesNumero = '09';
          break;
        case 10:
          _mes = 'Octubre';
          _mesNumero = '10';
          break;
        case 11:
          _mes = 'Noviembre';
          _mesNumero = '11';
          break;
        case 12:
          _mes = 'Diciembre';
          _mesNumero = '12';
          break;
        default:
      }
      setState(() {});

      _hoyLetra =
          "${_diaLetra} ${parsearFecha.day} de $_mes de ${parsearFecha.year}";

      String _diaNumero = parsearFecha.day.toString().padLeft(2, '0');
      _hoyNumero = "${parsearFecha.year}-$_mesNumero-$_diaNumero";

      //print(_hoyNumero);

      //roles para hoy
      final data = await SQLHelper.getTodayRoles(_id_usuario, _hoyNumero);
      //print(data);
      _rolesHoy = data;

      setState(() {});
      setLoading(false);
    });
  }

  goToClientList(idrol, idmarca, idot, geo) async {
    if (await ConnectivityWrapper.instance.isConnected) {
      //posicion de la tienda
      final combogeotienda = geo.split(",");

      //buscamos la posicion actual

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

      final geoiniciomision = _locationData.latitude.toString() +
          "," +
          _locationData.longitude.toString();

      //revisamos si ya existe la mision en la tabla misiones
      final data = await SQLHelper.getMissionExist(idrol, idmarca, idot);
      //print(data[0]['items']);
      int totalitems = data[0]['items'];

      if (totalitems > 0) {
        //no hacemos nada ya existe
      } else {
        //no existe la creamos

        DateTime dateToday = DateTime.now();
        final fechainiciomision = dateToday.toString().substring(0, 10);
        final horainiciomision = dateToday.toString().substring(11, 19);

        await SQLHelper.insertMission(idrol, idmarca, idot, fechainiciomision,
            horainiciomision, geoiniciomision);
      }

      final distance = calculateDistance(
          double.parse(combogeotienda[0]),
          double.parse(combogeotienda[1]),
          _locationData.latitude!,
          _locationData.longitude!);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('id_rol', idrol);
      await prefs.setInt('id_ot', idot);
      await prefs.setDouble('distance', distance.roundToDouble());
      await prefs.setInt('id_marca', idmarca);

      //cancelamos la subscription
      await _locationSubscription?.cancel();

      try {
        await FirebaseDatabase.instance
            .ref()
            .child('geolocalizaciones/$_id_usuario')
            .set({
          'idGuia': _id_usuario,
          'latitud': _lastLat,
          'longitud': _lastLong,
          'status': false
        });
      } catch (e) {
        print(e);
      }

      setState(() {
        _keepSavingGPS = false;
        _locationSubscription = null;
      });
      await prefs.setBool('keepSavingGPS', false);

      final route = MaterialPageRoute(builder: (context) {
        return Targets();
      });
      Navigator.push(context, route);
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(
              content: 'No hay conexión a internet para obtener tu ubicación'));
    }
  }

  uploadMission(idrol, idmarca, idot) async {
    setLoading(true);

    if (await ConnectivityWrapper.instance.isConnected) {
      //buscamos los datos
      final datos = await SQLHelper.getMision(idrol, idmarca, idot);
      //print(datos);

      //enviar datos mision
      String url2 = '${ServerInformation.API_ROOT}/misiones.php';
      var response2 = await Dio().post(
        url2,
        options: Options(
          headers: {
            'Apikey': '${Secret.secretID}',
          },
        ),
        data: jsonEncode({
          'misionrol_maestroid': idrol,
          'misionidmarca': idmarca,
          'misionidordentrabajo': idot,
          'fechainiciomision': datos[0]['fechainiciomision'],
          'horainiciomision': datos[0]['horainiciomision'],
          'geoiniciomision': datos[0]['geoiniciomision'],
          'pausasmision': datos[0]['pausasmision'],
          'reiniciosmision': datos[0]['reiniciosmision'],
          'prcomentarios': datos[0]['prcomentarios'],
          'fechaentregamision': datos[0]['fechaentregamision'],
          'horaentregamision': datos[0]['horaentregamision'],
          'geoentregamision': datos[0]['geoentregamision'],
          'soscausa': datos[0]['soscausa'],
          'soscomentario': datos[0]['soscomentario'],
          'status': datos[0]['status'],
        }),
      );
      final data2 = response2.data;
      print(data2);

      //buscamos los entregables
      final datos1 = await SQLHelper.getEntregablesByRol(idrol);
      //print(datos1);
      _entregables = datos1;
      setState(() {});

      //enviar entregables
      for (int i = 0; i < _entregables.length; i++) {
        if (_entregables[i]['entrega_nombre_elemento'] != 'Firma' &&
            _entregables[i]['entrega_nombre_elemento'] != 'Foto') {
          String url3 = '${ServerInformation.API_ROOT}/entregables.php';
          var response3 = await Dio().post(
            url3,
            options: Options(
              headers: {
                'Apikey': '${Secret.secretID}',
              },
            ),
            data: ({
              'entrega_rol_id': _entregables[i]['entregarolid'],
              'entrega_nombre_elemento': _entregables[i]
                  ['entrega_nombre_elemento'],
              'entrega_tipo_texto': _entregables[i]['entrega_tipo_texto'],
              'entrega_tipo_numero': _entregables[i]['entrega_tipo_numero'],
              'entrega_tipo_fecha': _entregables[i]['entrega_tipo_fecha'],
              'entrega_tipo_hora': _entregables[i]['entrega_tipo_hora'],
              'entrega_tipo_imagen': _entregables[i]['entrega_tipo_imagen'],
              'entrega_fecha_llegada': _entregables[i]['entrega_fecha_llegada'],
              'entrega_hora_llegada': _entregables[i]['entrega_hora_llegada'],
              'entrega_objetivo_id': _entregables[i]['entregaobjetivoid'],
              'entrega_hora_cierre': _entregables[i]['entregahoracierre'],
              'entrega_fecha_cierre': _entregables[i]['entregafechacierre']
            }),
          );
          final data3 = response3.data;
          print(data3);
        } else {
          if (_entregables[i]['entrega_nombre_elemento'] == 'Firma' ||
              _entregables[i]['entrega_nombre_elemento'] == 'Foto') {
            String fileName =
                _entregables[i]['entrega_tipo_imagen'].split('/').last;

            FormData data = FormData.fromMap({
              "imagen": await MultipartFile.fromFile(
                  _entregables[i]['entrega_tipo_imagen'],
                  filename: fileName),
              'entrega_rol_id': _entregables[i]['entregarolid'],
              'entrega_nombre_elemento': _entregables[i]
                  ['entrega_nombre_elemento'],
              'entrega_tipo_texto': _entregables[i]['entrega_tipo_texto'],
              'entrega_tipo_numero': _entregables[i]['entrega_tipo_numero'],
              'entrega_tipo_fecha': _entregables[i]['entrega_tipo_fecha'],
              'entrega_tipo_hora': _entregables[i]['entrega_tipo_hora'],
              'entrega_tipo_imagen': _entregables[i]['entrega_tipo_imagen'],
              'entrega_fecha_llegada': _entregables[i]['entrega_fecha_llegada'],
              'entrega_hora_llegada': _entregables[i]['entrega_hora_llegada'],
              'entrega_objetivo_id': _entregables[i]['entregaobjetivoid'],
              'entrega_hora_cierre': _entregables[i]['entregahoracierre'],
              'entrega_fecha_cierre': _entregables[i]['entregafechacierre']
            });
            String url3 = '${ServerInformation.API_ROOT}/entregables_files.php';
            var response3 = await Dio().post(url3,
                options: Options(
                  headers: {
                    'Apikey': '${Secret.secretID}',
                  },
                ),
                data: data);
            final data3 = response3.data;
            print(data3);
          }
        }
      }

      //marcar en  rolmaestromsiones local fecha y hora de subida
      DateTime dateToday = DateTime.now();
      final fechaentregamision = dateToday.toString().substring(0, 10);
      final horaentregamision = dateToday.toString().substring(11, 19);
      final fecha = fechaentregamision + " " + horaentregamision;
      final actualiza =
          await SQLHelper.updateRolWithFechaSubida(idrol, idmarca, idot, fecha);
      //print(actualiza);

      //actualizamos los roles para hoy
      final data = await SQLHelper.getTodayRoles(_id_usuario, _hoyNumero);
      //print(data);
      _rolesHoy = data;

      setState(() {});
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(
              content: 'No hay conexión a internet para subir la misión'));
    }
    setLoading(false);
  }

  shopLocation(idrol) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('location_id_rol', idrol);

    //cancelamos la subscription
    await _locationSubscription?.cancel();

    try {
      await FirebaseDatabase.instance
          .ref()
          .child('geolocalizaciones/$_id_usuario')
          .set({
        'idGuia': _id_usuario,
        'latitud': _lastLat,
        'longitud': _lastLong,
        'status': false
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      _keepSavingGPS = false;
      _locationSubscription = null;
    });
    await prefs.setBool('keepSavingGPS', false);

    final route = MaterialPageRoute(builder: (context) {
      return ShopDetail();
    });
    Navigator.push(context, route);
  }

  _saveGPS(lat, long) async {
    print("Status del keep saving " + _keepSavingGPS.toString());
    if (_keepSavingGPS == true) {
      _lastLat = lat;
      _lastLong = long;
      try {
        await FirebaseDatabase.instance
            .ref()
            .child('geolocalizaciones/$_id_usuario')
            .set({
          'idGuia': _id_usuario,
          'latitud': lat,
          'longitud': long,
          'status': true
        });
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else {
      return false;
    }
  }

  _startTracking() async {
    _keepSavingGPS = true;
    setState(() {});

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepSavingGPS', true);

    //solicitar permiso
    Location location = new Location();
    LocationData _locationData;

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    //obtener ubicacion
    _locationData = await location.getLocation();
    print(_locationData);

    //guardamos en firebase
    bool respuesta =
        await _saveGPS(_locationData.latitude, _locationData.longitude);
    if (respuesta) {
      print("Se guardo GPS en firebase");
    } else {
      print("GPS no se guardo en firebase");
    }

    //escuchar en segundo plano
    //location.enableBackgroundMode(enable: true);

    //acciones al cambiar de ubicacion
    _locationSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) async {
      // Use current location
      print(currentLocation);
      bool resp =
          await _saveGPS(currentLocation.latitude, currentLocation.longitude);
      if (resp) {
        print("Se guardo GPS");
      } else {
        print("Error al guardar GPS");
      }
    });
  }

  _stopTracking() async {
    await _locationSubscription?.cancel();

    try {
      await FirebaseDatabase.instance
          .ref()
          .child('geolocalizaciones/$_id_usuario')
          .set({
        'idGuia': _id_usuario,
        'latitud': _lastLat,
        'longitud': _lastLong,
        'status': false
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      _keepSavingGPS = false;
      _locationSubscription = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepSavingGPS', false);
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
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
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
            "Misiones",
            style: TextStyle(color: Colors.white),
          ),
          toolbarHeight: 70,
          excludeHeaderSemantics: true,
          actions: [
            Container(
                padding: EdgeInsets.only(right: 10, bottom: 12),
                child:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('Ver. ${Version.VersionNumber}',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ])),
          ],
          automaticallyImplyLeading: false,
        ),
        //drawer: MenuWidget(),
        body: (loading == true)
            ? LoadingDialog()
            : ListView(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Color(0xfffcfcfc),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0)),
                          //border: Border.all(color: Color(0xffa2a2a2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _hoyLetra != null ? _hoyLetra.toString() : '',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text(
                              'Estas son tus misiones de hoy',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            _keepSavingGPS == false
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 45),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _startTracking();
                                      },
                                      icon: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Icon(
                                          Icons.my_location,
                                          size: 20.0,
                                        ),
                                      ),
                                      label: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Compartir posición',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  side: BorderSide(
                                                      color:
                                                          Color(0xFF26bf94)))),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          //shape: MaterialStateProperty.all(StadiumBorder()),
                                          elevation:
                                              MaterialStateProperty.all(0),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color(0xFF26bf94)),
                                          padding: MaterialStateProperty.all(
                                            EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                          )),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 45),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        _stopTracking();
                                      },
                                      icon: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Icon(
                                          Icons.my_location,
                                          size: 20.0,
                                        ),
                                      ),
                                      label: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Dejar de compartir posición',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  side: BorderSide(
                                                      color:
                                                          Color(0xFFe55c6f)))),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          //shape: MaterialStateProperty.all(StadiumBorder()),
                                          elevation:
                                              MaterialStateProperty.all(0),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Color(0xFFe55c6f)),
                                          padding: MaterialStateProperty.all(
                                            EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                          )),
                                    ),
                                  )

/*
                          SizedBox(
                              height: 5.0,
                          ),
                          FlatTextButton(
                            onPressed: () {
                              checkin();
                            },
                            edgeInsetsPadding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 50),
                            color: Color(0xFF129fd6),
                            text: Text(
                              'Checkin',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
  */
/*
                          FlatTextButton(
                            onPressed: () {
                              final route =
                                  MaterialPageRoute(builder: (context) {
                                return DatabaseMenu();
                              });
                              Navigator.push(context, route);
                            },
                            edgeInsetsPadding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 50),
                            color: Color(0xFF129fd6),
                            text: Text(
                              'Databases',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(
                            height: 10.0,
                          ),
                          
*/
                          ],
                        ),
                      ),
                    ],
                  ),
                  _rolesHoy.length > 0
                      ? Container(
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _rolesHoy.length,
                              itemBuilder: (context, index) {
                                var Mission = _rolesHoy[index];
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2, // 20%
                                        child: IconButton(
                                          onPressed: () {
                                            shopLocation(
                                                Mission['rolmaestroid']);
                                          },
                                          icon: Icon(
                                            Icons.location_on,
                                            color: Color(0xFFe55c6f),
                                            size: 40.0,
                                          ),
                                        ),
                                      ),
                                      if (Mission['fechaentregamision'] == "" ||
                                          Mission['fechaentregamision'] ==
                                              null) ...[
                                        Expanded(
                                          flex: 6, // 60%
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(Mission['nombretienda'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),

                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                Mission['ubicaciontienda'],
                                                style: TextStyle(fontSize: 12),
                                              ),

                                              //Text("Sin Entregar")
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2, // 20%
                                          child: IconButton(
                                              onPressed: () {
                                                goToClientList(
                                                    Mission['rolmaestroid'],
                                                    Mission['rolmarcaid'],
                                                    Mission[
                                                        'rolidordentrabajo'],
                                                    Mission['geotienda']);
                                              },
                                              icon: Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Color(0xFF26bf94),
                                                size: 40.0,
                                              )),
                                        ),
                                      ] else ...[
                                        Expanded(
                                          flex: 6, // 80%
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(Mission['nombretienda'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),

                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(Mission['ubicaciontienda']),

                                              //Text("Entregado")
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2, // 20%
                                          child: IconButton(
                                            onPressed: () {
                                              uploadMission(
                                                  Mission['rolmaestroid'],
                                                  Mission['rolmarcaid'],
                                                  Mission['rolidordentrabajo']);
                                            },
                                            icon: Icon(
                                              Icons.keyboard_arrow_up,
                                              color: Color(0xff111c43),
                                              size: 40.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
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
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    "Por el momento no tienes misiones asignadas."),
                                SizedBox(height: 10),
                                FlatTextButton(
                                  onPressed: () async {
                                    //cancelamos la subscription
                                    await _locationSubscription?.cancel();

                                    try {
                                      await FirebaseDatabase.instance
                                          .ref()
                                          .child(
                                              'geolocalizaciones/$_id_usuario')
                                          .set({
                                        'idGuia': _id_usuario,
                                        'latitud': _lastLat,
                                        'longitud': _lastLong,
                                        'status': false
                                      });
                                    } catch (e) {
                                      print(e);
                                    }

                                    setState(() {
                                      _keepSavingGPS = false;
                                      _locationSubscription = null;
                                    });
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool('keepSavingGPS', false);

                                    final route =
                                        MaterialPageRoute(builder: (context) {
                                      return Home();
                                    });
                                    Navigator.push(context, route);
                                  },
                                  edgeInsetsPadding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  color: Color(0xff111c43),
                                  text: Text(
                                    'Verificar',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFDEE8E8),
              icon: Image(
                image: AssetImage('assets/img/icon4.png'),
                height: 30,
                color: Color(0xFF26bf94),
              ),
              label: 'A',
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFDEE8E8),
              activeIcon: Image(
                image: AssetImage('assets/img/icon2.png'),
                height: 30,
                color: Color(0xFF129fd6),
              ),
              icon: Image(
                image: AssetImage('assets/img/icon2.png'),
                height: 30,
                color: Color(0xFF129fd6),
              ),
              label: 'C',
            ),
            BottomNavigationBarItem(
              backgroundColor: Color(0xFFDEE8E8),
              icon: Image(
                image: AssetImage('assets/img/icon1.png'),
                height: 30,
                color: Color(0xFF845adf),
              ),
              label: 'D',
            ),
          ],
          currentIndex: 1,
          selectedItemColor: Color(0xFF00b9a3),
          unselectedItemColor: Color(0xFF00b9a3),
          onTap: _onTap,
        ));
  }

  void _onTap(int index) async {
    if (index == 0) {
      //cancelamos la subscription
      await _locationSubscription?.cancel();
      try {
        await FirebaseDatabase.instance
            .ref()
            .child('geolocalizaciones/$_id_usuario')
            .set({
          'idGuia': _id_usuario,
          'latitud': _lastLat,
          'longitud': _lastLong,
          'status': false
        });
      } catch (e) {
        print(e);
      }

      setState(() {
        _keepSavingGPS = false;
        _locationSubscription = null;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('keepSavingGPS', false);

      final route = MaterialPageRoute(builder: (context) {
        return Shops();
      });
      Navigator.push(context, route);
    }

    if (index == 1) {
      //cancelamos la subscription
      await _locationSubscription?.cancel();
      try {
        await FirebaseDatabase.instance
            .ref()
            .child('geolocalizaciones/$_id_usuario')
            .set({
          'idGuia': _id_usuario,
          'latitud': _lastLat,
          'longitud': _lastLong,
          'status': false
        });
      } catch (e) {
        print(e);
      }
      setState(() {
        _keepSavingGPS = false;
        _locationSubscription = null;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('keepSavingGPS', false);

      final route = MaterialPageRoute(builder: (context) {
        return Home();
      });
      Navigator.push(context, route);
    }

    if (index == 2) {
      //cancelamos la subscription
      await _locationSubscription?.cancel();
      try {
        await FirebaseDatabase.instance
            .ref()
            .child('geolocalizaciones/$_id_usuario')
            .set({
          'idGuia': _id_usuario,
          'latitud': _lastLat,
          'longitud': _lastLong,
          'status': false
        });
      } catch (e) {
        print(e);
      }
      setState(() {
        _keepSavingGPS = false;
        _locationSubscription = null;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('keepSavingGPS', false);

      final route = MaterialPageRoute(builder: (context) {
        return Profile();
      });
      Navigator.push(context, route);
    }
  }
}
