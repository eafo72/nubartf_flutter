import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../dialogs/loading-dialog.dart';
import '../shared/buttons.dart';
import '../widgets/menu_inferior_home.dart';
import 'login.dart';
import 'travelMoney.dart';

import '../sqlhelper.dart';

import '../utils/url-launcher-utils.dart';

class DayDetails extends StatefulWidget {
  static const String routeName = 'daydetails';

  DayDetails({Key? key}) : super(key: key);

  @override
  State<DayDetails> createState() => _DayDetailsState();
}

class _DayDetailsState extends State<DayDetails> {
  bool loading = false;

  bool? _logged;

  int? _id_usuario;
  String? _fecha;

  String? _mes;
  String? _mesNumero;
  String? _diaLetra;
  String? _hoyLetra;
  String? _hoyNumero;

  List<Map<String, dynamic>> _rolesFecha = [];

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _logged = prefs.getBool('logged');
    _fecha = prefs.getString('dayDetails');

    final parsearFecha = DateTime.parse(_fecha!);

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

    _hoyLetra = "${_diaLetra} ${parsearFecha.day} de $_mes de ${parsearFecha.year}";

    await prefs.setString('last_nav_position', "dayDetails");

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

    //roles por fecha
    final data = await SQLHelper.getRolesByDate(_fecha);
    print(data);
    _rolesFecha = data;

    setState(() {});

    setLoading(false);
  }

  goToTravelMoney(idot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('idotTravelMoney', idot);

    final route = MaterialPageRoute(builder: (context) {
      return TravelMoney();
    });
    Navigator.push(context, route);
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
          "Detalle de actividades",
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
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xfffcfcfc),
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                    //border: Border.all(color: Color(0xffa2a2a2)),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Text("$_hoyLetra",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                _rolesFecha.length > 0
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _rolesFecha.length,
                          itemBuilder: (context, index) {
                            var Mission = _rolesFecha[index];
                            return Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.transparent,
                                ),
                                child: ListTile(
                                  title: Text(
                                      "Lugar: " + Mission['nombretienda'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Dirección:" +
                                          Mission['ubicaciontienda']),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("Encargado: " +
                                          Mission['encargadotienda']),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("Fecha programada: " +
                                          Mission['fechaprogramadavisitarol']
                                              .toString()),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("Hora programada: " +
                                          Mission['horaprogramadavisitarol']
                                              .toString()),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text("Fecha y hora de entrega: " +
                                          Mission['fechayhorasubida']
                                              .toString()),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(children: [
                                        IconButton(
                                            icon: Icon(
                                              Icons.pageview,
                                              color: Color(0xFF111c43),
                                              size: 30.0,
                                            ),
                                            onPressed: () {
                                              //print("https://nubartf.com/consultar_tienda_info_app.php?id="+Mission['rolmaestroid'].toString()+"&ot="+Mission['rolidordentrabajo'].toString()+"&tid="+Mission['rolidtienda'].toString());
                                              launchInBrowser(Uri.parse(
                                                  "https://nubartf.com/consultar_tienda_info_app.php?id=" +
                                                      Mission['rolmaestroid']
                                                          .toString() +
                                                      "&ot=" +
                                                      Mission['rolidordentrabajo']
                                                          .toString() +
                                                      "&tid=" +
                                                      Mission['rolidtienda']
                                                          .toString()));
                                            }),
                                        IconButton(
                                            icon: Icon(
                                              Icons.card_travel,
                                              color: Color(0xFF111c43),
                                              size: 25.0,
                                            ),
                                            onPressed: () {
                                              goToTravelMoney(
                                                  Mission['rolidordentrabajo']);
                                            }),
                                      ])
                                    ],
                                  ),
                                ));
                          },
                        ),
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
                              Text("No existen actividades"),
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
