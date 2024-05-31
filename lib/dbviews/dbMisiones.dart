import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/loading-dialog.dart';
import '../views/login.dart';
import '../widgets/menu_inferior_home.dart';

import '../sqlhelper.dart';


class DBMisiones extends StatefulWidget {
  static const String routeName = 'db_misiones';

  DBMisiones({Key? key}) : super(key: key);

  @override
  State<DBMisiones> createState() => _DBMisionesState();
}

class _DBMisionesState extends State<DBMisiones> {
  bool loading = false;

  bool? _logged;

  List<Map<String, dynamic>> _misiones = [];

 
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

    //roles por fecha
    final data = await SQLHelper.getMisiones();
    _misiones = data;

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
                        child: Text("Misiones",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),


               _misiones.length > 0
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _misiones.length,
                          itemBuilder: (context, index) {
                            var Mission = _misiones[index];
                            return Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.symmetric(vertical: 5),
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
                                child: ListTile(
        
                                  title: Text("Rol ID: "+Mission['misionrol_maestroid'].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("OT ID:" + Mission['misionidordentrabajo'].toString()),
                                      Text("Marca ID:" + Mission['misionidmarca'].toString()),
                                      Text("Fecha Inicio:" + Mission['fechainiciomision']),
                                      Text("Hora Inicio:" + Mission['horainiciomision']),
                                      Text("GeoLocalización inicio:" + Mission['geoiniciomision']),
                                      Text("Pausas:" + Mission['pausasmision']),
                                      Text("Reinicios:" + Mission['reiniciosmision']),
                                      Text("PR Comentarios:" + Mission['prcomentarios']),
                                      Text("Fecha Entrega:" + Mission['fechaentregamision']),
                                      Text("Hora Entrega:" + Mission['horaentregamision']),
                                      Text("GeoLocalización:" + Mission['geoentregamision']),
                                      Text("SOS causa:" + Mission['soscausa']),
                                      Text("SOS comentario:" + Mission['soscomentario']),
                                      Text("Status:" + Mission['status']),
                                    ],
                                  ),
                                ));
                          },
                        ),
                      )
                    : Center(
                        child: Text("No existen misiones"),
                      ),
                
              ],
            ),
      bottomNavigationBar: MenuInferiorHome(btn1: 1,btn2: 1,btn3: 1,btn4: 1),
    );
  }
}
