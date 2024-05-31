import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/loading-dialog.dart';
import '../views/login.dart';
import '../widgets/menu_inferior_home.dart';

import '../sqlhelper.dart';


class DBObjetivosMarca extends StatefulWidget {
  static const String routeName = 'db_objetivos_marca';

  DBObjetivosMarca({Key? key}) : super(key: key);

  @override
  State<DBObjetivosMarca> createState() => _DBObjetivosMarcaState();
}

class _DBObjetivosMarcaState extends State<DBObjetivosMarca> {
  bool loading = false;

  bool? _logged;

  List<Map<String, dynamic>> _objetivosmarca = [];

 
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
    final data = await SQLHelper.getObjetivosMarca();
    _objetivosmarca = data;

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
                        child: Text("Objetivos Marca",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),


               _objetivosmarca.length > 0
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _objetivosmarca.length,
                          itemBuilder: (context, index) {
                            var Mission = _objetivosmarca[index];
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
                                  title: Text("Nombre: "+Mission['nombreobjetivo'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                     
                                      Text("Rol ID:" + Mission['idrol'].toString()),
                                      Text("Marca ID:" + Mission['idmarca'].toString()),
                                      Text("Objetivo ID:" + Mission['idobjetivo'].toString()),
                                      Text("Firma objetivo: " + Mission['firmaobjetivo']),
                                      Text("Imagen objetivo: " + Mission['imagenobjetivo']),
                                      Text("Realizado: " + Mission['realizado'].toString()),
                                      
                                      
                                    ],
                                  ),
                                ));
                          },
                        ),
                      )
                    : Center(
                        child: Text("No existen objetivos marca"),
                      ),
                


              ],
            ),
      bottomNavigationBar: MenuInferiorHome(btn1: 1,btn2: 1,btn3: 1,btn4: 1),
    );
  }
}
