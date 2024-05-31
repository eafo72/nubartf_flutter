import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/loading-dialog.dart';
import '../views/login.dart';
import '../widgets/menu_inferior_home.dart';

import '../sqlhelper.dart';


class DBEntregables extends StatefulWidget {
  static const String routeName = 'db_entregables';

  DBEntregables({Key? key}) : super(key: key);

  @override
  State<DBEntregables> createState() => _DBEntregablesState();
}

class _DBEntregablesState extends State<DBEntregables> {
  bool loading = false;

  bool? _logged;

  List<Map<String, dynamic>> _entregables = [];

 
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
    final data = await SQLHelper.getEntregables();
    _entregables = data;

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
                        child: Text("Entregables",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                    ],
                  ),
                ),


               _entregables.length > 0
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _entregables.length,
                          itemBuilder: (context, index) {
                            var Mission = _entregables[index];
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
                                  title: Text("Nombre: "+Mission['entrega_nombre_elemento'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [

                                     
                                      Text("Rol ID:" + Mission['entregarolid'].toString()),
                                      Text("Objetivo ID:" + Mission['entregaobjetivoid'].toString()),
                                      
                                      Text("Tipo texto: " + Mission['entrega_tipo_texto']),
                                      Text("Tipo numero: " + Mission['entrega_tipo_numero']),
                                      Text("Tipo fecha: " + Mission['entrega_tipo_fecha']),
                                      Text("Tipo hora: " + Mission['entrega_tipo_hora']),

/*
                                      if(Mission['entrega_tipo_imagen'].length > 50)
                                      ...[
                                        Text("Tipo imagen: " + Mission['entrega_tipo_imagen'].substring(0,50))
                                        ]
                                        else
                                      ...[
                                        Text("Tipo imagen: " + Mission['entrega_tipo_imagen']),
                                      ],
                                      */
                                      if(Mission['entrega_tipo_imagen'] != '' && Mission['entrega_tipo_imagen'] != null)
                                      ...[

                                        if(Mission['entrega_nombre_elemento'] == 'Foto')...[  
                                          /*
                                          Image.memory(
                                            base64Decode(Mission['entrega_tipo_imagen']),
                                            fit: BoxFit.fill,
                                          ),*/
                                          Image.file(
                                            File(Mission['entrega_tipo_imagen']),
                                            width: 100,
                                            height: 100,
                                            ),
                                          Text("Tipo imagen: " + Mission['entrega_tipo_imagen']),

                                        ],

                                        if(Mission['entrega_nombre_elemento'] == 'Firma')...[  
                                          
                                          Image.file(
                                            File(Mission['entrega_tipo_imagen']),
                                            width: 100,
                                            height: 100,
                                            ),
                                          Text("Tipo imagen: " + Mission['entrega_tipo_imagen']),
                                        ]



                                      ],
                                      
                                      Text("Tipo audio: " + Mission['entrega_tipo_audio']),

                                      Text("Fecha inicio: " + Mission['entrega_fecha_llegada']),
                                      Text("Hora inicio: " + Mission['entrega_hora_llegada']),

                                      Text("Fecha fin: " + Mission['entregafechacierre']),
                                      Text("Hora fin: " + Mission['entregahoracierre']),
                                      
                                      
                                    ],
                                  ),
                                ));
                          },
                        ),
                      )
                    : Center(
                        child: Text("No existen entregables"),
                      ),
                


              ],
            ),
      bottomNavigationBar: MenuInferiorHome(btn1: 1,btn2: 1,btn3: 1,btn4: 1),
    );
  }
}
