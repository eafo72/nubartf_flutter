import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:nubartf/shared/buttons.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../dialogs/loading-dialog.dart';
import '../widgets/menu_inferior_home.dart';
import 'login.dart';

import '../sqlhelper.dart';

class ShopDetail extends StatefulWidget {
  static const String routeName = 'shop_detail';

  ShopDetail({Key? key}) : super(key: key);

  @override
  State<ShopDetail> createState() => _ShopDetailState();
}

class _ShopDetailState extends State<ShopDetail> {
  bool loading = false;

  bool? _logged;

  String? _mes;
  String? _mesNumero;
  String? _hoyLetra;
  String? _hoyNumero;

  int? _id_usuario;
  int? _id_rol;
  String? _direcciontienda;
  String? _nombretienda;

  List<Map<String, dynamic>> _rolesHoy = [];

  //para el mapa
  GoogleMapController? mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _centerView();
  }

  List<LatLng> positions = [];
  Set<Marker> markers = {};

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _logged = prefs.getBool('logged');
    _id_rol = prefs.getInt('location_id_rol');

    await prefs.setString('last_nav_position', "shopDetail");

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

    final parsearFecha = DateTime.now();
    //final formatoFecha = DateFormat('MMMM dd, yyyy').format(parsearFecha);
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

    _hoyLetra = "${parsearFecha.day} de $_mes de ${parsearFecha.year}";

    String _diaNumero = parsearFecha.day.toString().padLeft(2, '0');
    _hoyNumero = "${parsearFecha.year}-$_mesNumero-$_diaNumero";

    //print(_hoyNumero);

    //roles para hoy
    final data = await SQLHelper.getTodayRoles(_id_usuario, _hoyNumero);
    //print(data);

    _rolesHoy = data; //guardamos la lista

    //agregamos los markers
    for (int i = 0; i < _rolesHoy.length; i++) {
      if (_rolesHoy[i]['geotienda'] != '' &&
          _rolesHoy[i]['rolmaestroid'] == _id_rol) {
        String coordenadas = _rolesHoy[i]['geotienda'];
        _nombretienda = _rolesHoy[i]['nombretienda'];
        _direcciontienda = _rolesHoy[i]['ubicaciontienda'];
        final List<String> combo_coordenadas = coordenadas.split(',');
        double itemlatitud = double.parse(combo_coordenadas[0]);
        double itemlongitud = double.parse(combo_coordenadas[1]);

        //agregamos las coordenadas a la lista de posiciones
        positions.add(LatLng(itemlatitud, itemlongitud));

        markers.add(Marker(
          markerId: MarkerId(_rolesHoy[i]['geotienda']),
          position: LatLng(itemlatitud, itemlongitud), //position of marker
          infoWindow: InfoWindow(
            //popup info
            title: _rolesHoy[i]['nombretienda'],
            snippet: _rolesHoy[i]['nombretienda'],
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
        ));
      }
    }

    setState(() {});
    setLoading(false);
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    //assert(list.isNotEmpty);
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
        northeast: LatLng(x1 as double, y1 as double),
        southwest: LatLng(x0 as double, y0 as double));
  }

  _centerView() async {
    //await _mapController.getVisibleRegion();

    if (positions.length == 1) {
      var cameraUpdate = CameraUpdate.newLatLngZoom(positions[0], 6.0);
      mapController!.animateCamera(cameraUpdate);
    } else if (positions.length > 1) {
      var bounds = boundsFromLatLngList(positions);
      // Create the camera update with the bounds calculated
      var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
      mapController!.animateCamera(cameraUpdate);
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
    _centerView();
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
          "Ubicación",
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
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xfffcfcfc),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        //border: Border.all(color: Color(0xffa2a2a2)),
                      ),
                      child: Column(
                        children: [
                          //Contactanos

                          Text(
                            _nombretienda.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            _direcciontienda.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 400,
                  child: GoogleMap(
                    scrollGesturesEnabled: true,
                    gestureRecognizers: Set()
                      ..add(Factory<PanGestureRecognizer>(
                          () => PanGestureRecognizer()))
                      ..add(
                        Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer()),
                      )
                      ..add(
                        Factory<HorizontalDragGestureRecognizer>(
                            () => HorizontalDragGestureRecognizer()),
                      )
                      ..add(
                        Factory<ScaleGestureRecognizer>(
                            () => ScaleGestureRecognizer()),
                      ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(23.6050079, -104.6830513),
                      zoom: 4.0,
                    ),
                    key: ValueKey('uniqueey'),
                    onMapCreated: _onMapCreated,
                    markers: markers,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: FlatTextButton(
                    onPressed: () {
                      _centerView();
                    },
                    edgeInsetsPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    color: Color(0xff111c43),
                    text: Text(
                      'Center View',
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
