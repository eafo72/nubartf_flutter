import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../config/constants.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_checker/connectivity_checker.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../dialogs/attention-dialog.dart';
import '../dialogs/loading-dialog.dart';
import '../dialogs/successful-dialog.dart';

import '../shared/buttons.dart';
import '../widgets/menu_inferior_home.dart';
import 'login.dart';

class TravelMoney extends StatefulWidget {
  static const String routeName = 'TravelMoney';

  TravelMoney({Key? key}) : super(key: key);

  @override
  State<TravelMoney> createState() => _TravelMoneyState();
}

class _TravelMoneyState extends State<TravelMoney> {
  bool loading = false;
  bool? _logged;

  int? _idot;

  final _job_foto = TextEditingController();
  final _job_concepto = TextEditingController();
  final _job_fecha = TextEditingController();
  final _job_importe = TextEditingController();

  List _viaticos = [];

  final _picker = ImagePicker();
  XFile? pickedPhoto;
  File? pickedPhotoFile;

  FilePickerResult? pickedFile;

  _saveForm() async {
    setLoading(true);

    if (await ConnectivityWrapper.instance.isConnected) {
      //REVISAMOS QUE TODOS LOS JOBS ESTEN TERMINADOS

      if (_job_fecha.text.isEmpty) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AttentionDialog(content: "Selecciona la fecha"));
      } else if (_job_concepto.text.isEmpty) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AttentionDialog(content: "Escribe el concepto"));
      } else if (_job_foto.text.isEmpty) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                AttentionDialog(content: "Toma una foto del comprobante"));
      } else if (_job_importe.text.isEmpty) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AttentionDialog(content: "Escribe el importe"));
      } else {
        // enviamos info
        String fileName = _job_foto.text.split('/').last;

        FormData data = FormData.fromMap({
          "imagen":
              await MultipartFile.fromFile(_job_foto.text, filename: fileName),
          'id_ot': _idot,
          'fecha': _job_fecha.text,
          'concepto': _job_concepto.text,
          'importe': _job_importe.text
        });

        String url3 = '${ServerInformation.API_ROOT}/viaticos.php';
        var response3 = await Dio().post(url3,
            options: Options(
              headers: {
                'Apikey': '${Secret.secretID}',
              },
            ),
            data: data);
        final data3 = response3.data;
        print(data3);

        if (data3['error'] == false) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => SuccessfulDialog(
                  content: 'Comprobante guardado',
                  title: '¡FELICIDADES!',
                  onOk: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => super.widget));
                  }));
        } else {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AttentionDialog(content: data3['mensaje']));
        }
      }
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(
              content: 'No hay conexión a internet para subir la misión'));
    }
    setLoading(false);
  }

  Future getPhoto() async {
    try {
      pickedPhoto = await _picker.pickImage(
          source: ImageSource.camera, maxWidth: 960, maxHeight: 1280);
      if (pickedPhoto != null) {
        //convertimos la imagen a file
        pickedPhotoFile = File(pickedPhoto!.path);
        String dir = (await getApplicationDocumentsDirectory()).path;
        File savedImage = await pickedPhotoFile!.copy("$dir/" +
            DateTime.now().millisecondsSinceEpoch.toString() +
            ".jpg");

        setState(() {
          _job_foto.text = savedImage.path;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _logged = prefs.getBool('logged');
    _idot = prefs.getInt('idotTravelMoney');

    await prefs.setString('last_nav_position', "travelMoney");

    //PEDIR LOS MOVIMIENTOS ANTERIORES
    String url =
        '${ServerInformation.API_ROOT}/viaticos.php?opcion=1&idot=${_idot}';
    var response = await Dio().get(
      url,
      options: Options(
        headers: {
          'Apikey': '${Secret.secretID}',
        },
      ),
    );
    final data = response.data;
    print(data);
    if (data != null) {
      _viaticos = data;
    }

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

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
          "Viáticos",
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
              shrinkWrap: true,
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
                      Center(
                        child: Text("Gastos",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),

                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _viaticos.length,
                        itemBuilder: (context, index) {
                          var Item = _viaticos[index];
                          return Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.transparent,
                              ),
                              child: index != _viaticos.length - 1
                                  ? ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //fecha
                                          Text(Item['fecha'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(
                                            width: 5.0,
                                          ),

                                          //concepto
                                          (Text(Item['concepto'],
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal))),
                                          SizedBox(
                                            width: 5.0,
                                          ),

                                          //importe
                                          (Text("\$ " + Item['importe'],
                                              style: TextStyle(
                                                  fontWeight:
                                                      FontWeight.normal))),
                                          (Text(Item['status'],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: Item['status'] ==
                                                          'Rechazado'
                                                      ? Colors.red
                                                      : Item['status'] ==
                                                              'Aceptado'
                                                          ? Colors.green
                                                          : Colors.black))),
                                        ],
                                      ),
                                    )
                                  : (ListTile(
                                      title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                          Text(
                                            "Total: \$ " + Item['importe'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 22),
                                          )
                                        ]))));
                        },
                      ),
                      SizedBox(
                        height: 50.0,
                      ),

                      //Contactanos
                      Center(
                        child: Text("Nuevo gasto",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        TextField(
                          controller: _job_fecha,
                          decoration: InputDecoration(
                              icon: Icon(Icons.calendar_today),
                              labelText: "Selecciona la fecha"),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime(2100));
                            if (pickedDate != null) {
                              _job_fecha.text =
                                  DateFormat('yyyy-MM-dd').format(pickedDate);
                            }
                          },
                        ),
                        TextField(
                          controller: _job_concepto,
                          decoration: InputDecoration(
                              icon: Icon(Icons.comment), //icon of text field
                              labelText:
                                  "Escribe el concepto" //label text of field
                              ),
                        ),
                        TextField(
                          controller: _job_foto,
                          decoration: InputDecoration(
                              icon: Icon(Icons.photo),
                              labelText: "Foto del comprobante"),
                          readOnly: true,
                          onTap: () async {
                            getPhoto();
                          },
                        ),
                        TextField(
                          controller: _job_importe,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              icon:
                                  Icon(Icons.attach_money), //icon of text field
                              labelText:
                                  "Escribe el importe" //label text of field
                              ),
                        ),
                      ],
                    )),
                SizedBox(height: 30),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: FlatTextButton(
                    onPressed: () {
                      _saveForm();
                    },
                    edgeInsetsPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    color: Color(0xff111c43),
                    text: Text(
                      'Guardar',
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

      bottomNavigationBar: MenuInferiorHome(btn1: 1, btn2: 1, btn3: 1, btn4: 1),
      
    );
  }
}
