import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_signature_pad/easy_signature_pad.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../config/constants.dart';
import '../dialogs/attention-dialog.dart';
import '../dialogs/loading-dialog.dart';
import '../shared/buttons.dart';
import '../widgets/menu_inferior.dart';
import 'login.dart';

import '../sqlhelper.dart';
import 'targets.dart';

class TargetDetail extends StatefulWidget {
  static const String routeName = 'targetdetail';

  TargetDetail({Key? key}) : super(key: key);

  @override
  State<TargetDetail> createState() => _TargetDetailState();
}

class _TargetDetailState extends State<TargetDetail> {
  bool loading = false;

  bool? _logged;

  int? _id_usuario;

  int? _id_rol;
  int? _id_objetivo_marca;
  int? _id_objetivo;
  String? _nombre_objetivo;
  String? _firma_objetivo;
  String? _codigoqr_objetivo;
  int? _id_tienda;

  String? _fecha_inicio_objetivo;
  String? _hora_inicio_objetivo;

  String? _fecha_fin_objetivo;
  String? _hora_fin_objetivo;

  List<Map<String, dynamic>> _jobs = [];

  final _job_fecha = TextEditingController();
  final _job_comentario = TextEditingController();
  final _job_cantidad = TextEditingController();
  final _job_hora = TextEditingController();
  final _job_foto = TextEditingController();
  final _job_audio = TextEditingController();
  final _job_firma = TextEditingController();
  final _job_codigoqr = TextEditingController();

  final _picker = ImagePicker();
  XFile? pickedPhoto;
  File? pickedPhotoFile;

  FilePickerResult? pickedFile;

  bool? allJobsFinished = true;
  String? unfinishedJobsMessage;

  //para la firma
  Uint8List? signatureBytes;

  Future cargarData() async {
    setLoading(true);

    //seteamos la fecha y hora de inicio del objetivo
    DateTime dateToday = DateTime.now();
    _fecha_inicio_objetivo = dateToday.toString().substring(0, 10);
    _hora_inicio_objetivo = dateToday.toString().substring(11, 19);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _logged = prefs.getBool('logged');
    _id_rol = prefs.getInt('id_rol');
    _id_objetivo_marca = prefs.getInt('id_objetivo_marca');
    _id_objetivo = prefs.getInt('id_objetivo');
    _nombre_objetivo = prefs.getString('nombre_objetivo');
    _firma_objetivo = prefs.getString('firma_objetivo');
    _id_tienda = prefs.getInt('id_tienda');

    await prefs.setString('last_nav_position', "targetDetail");

    //recogemos los valores guardados en temp
    _job_fecha.addListener(_tempSaveFecha);
    _job_comentario.addListener(_tempSaveComentario);
    _job_cantidad.addListener(_tempSaveCantidad);
    _job_hora.addListener(_tempSaveHora);
    _job_foto.addListener(_tempSaveFoto);
    _job_firma.addListener(_tempSaveFirma);
    _job_codigoqr.addListener(_tempSaveQR);

    //buscamos la tienda para ver si incluye codigoqr
    final store_data = await SQLHelper.getTiendaById(_id_tienda);
    //print("Código qr : "+store_data[0]['codigoqr']);
    _codigoqr_objetivo = store_data[0]['codigoqr'].toString();

    if (prefs.getString('_job_fechaSaved$_id_rol') != null) {
      _job_fecha.text = prefs.getString('_job_fechaSaved$_id_rol').toString();
    }

    if (prefs.getString('_job_comentarioSaved$_id_rol') != null) {
      _job_comentario.text =
          prefs.getString('_job_comentarioSaved$_id_rol').toString();
    }

    if (prefs.getString('_job_cantidadSaved$_id_rol') != null) {
      _job_cantidad.text =
          prefs.getString('_job_cantidadSaved$_id_rol').toString();
    }

    if (prefs.getString('_job_horaSaved$_id_rol') != null) {
      _job_hora.text = prefs.getString('_job_horaSaved$_id_rol').toString();
    }

    if (prefs.getString('_job_fotoSaved$_id_rol') != null) {
      _job_foto.text = prefs.getString('_job_fotoSaved$_id_rol').toString();
    }

    if (prefs.getString('_job_firmaSaved$_id_rol') != null) {
      _job_firma.text = prefs.getString('_job_firmaSaved$_id_rol').toString();
    }

    if (prefs.getString('_job_codigoqrSaved$_id_rol') != null) {
      _job_codigoqr.text =
          prefs.getString('_job_codigoqrSaved$_id_rol').toString();
    }

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

    //jobs del objetivo
    final data = await SQLHelper.getTareasDelObjetivo(_id_objetivo);
    //print(data);
    _jobs = data;

    setState(() {});

    setLoading(false);
  }

  _saveForm() async {
    DateTime dateToday = DateTime.now();
    _fecha_fin_objetivo = dateToday.toString().substring(0, 10);
    _hora_fin_objetivo = dateToday.toString().substring(11, 19);
    setState(() {});

    //REVISAMOS QUE TODOS LOS JOBS ESTEN TERMINADOS
    for (int i = 0; i < _jobs.length; i++) {
      //fecha
      if (_jobs[i]['nombreelemento'] == 'Fecha') {
        if (_job_fecha.text.isEmpty) {
          setState(() {
            allJobsFinished = false;
            unfinishedJobsMessage = 'Selecciona la fecha';
          });
          break;
        }
      }

      //comentario
      if (_jobs[i]['nombreelemento'] == 'Comentario') {
        if (_job_comentario.text.isEmpty) {
          setState(() {
            allJobsFinished = false;
            unfinishedJobsMessage = 'Escribe un comentario';
          });
          break;
        }
      }

      //foto
      if (_jobs[i]['nombreelemento'] == 'Foto') {
        if (_job_foto.text.isEmpty) {
          setState(() {
            allJobsFinished = false;
            unfinishedJobsMessage = 'Toma una foto';
          });
          break;
        }
      }

      //cantidad
      if (_jobs[i]['nombreelemento'] == 'Cantidad') {
        if (_job_cantidad.text.isEmpty) {
          setState(() {
            allJobsFinished = false;
            unfinishedJobsMessage = 'Escribe una cantidad';
          });
          break;
        }
      }

      //audio
      if (_jobs[i]['nombreelemento'] == 'Audio') {
        if (_job_audio.text.isEmpty) {
          setState(() {
            allJobsFinished = false;
            unfinishedJobsMessage = 'Selecciona un audio';
          });
          break;
        }
      }

      //hora
      if (_jobs[i]['nombreelemento'] == 'Hora') {
        if (_job_hora.text.isEmpty) {
          setState(() {
            allJobsFinished = false;
            unfinishedJobsMessage = 'Seleccione una hora';
          });
          break;
        }
      }
    }
    if (_firma_objetivo == 'Si') {
      if (_job_firma.text.isEmpty) {
        setState(() {
          allJobsFinished = false;
          unfinishedJobsMessage = 'Haz tu firma';
        });
      }
    }

    if (_codigoqr_objetivo == 'Si') {
      if (_job_codigoqr.text.isEmpty) {
        setState(() {
          allJobsFinished = false;
          unfinishedJobsMessage = 'Escanea el código QR';
        });
      }
    }

    if (allJobsFinished == true) {
      //borramos lo que teniamos en sharedpreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('_job_fechaSaved$_id_rol');
      prefs.remove('_job_comentarioSaved$_id_rol');
      prefs.remove('_job_cantidadSaved$_id_rol');
      prefs.remove('_job_horaSaved$_id_rol');
      prefs.remove('_job_fotoSaved$_id_rol');
      prefs.remove('_job_firmaSaved$_id_rol');
      prefs.remove('_job_codigoqrSaved$_id_rol');

      for (int i = 0; i < _jobs.length; i++) {
        //fecha
        if (_jobs[i]['nombreelemento'] == 'Fecha') {
          await SQLHelper.saveEntregable(
              _id_rol,
              'Fecha',
              '',
              '',
              _job_fecha.text,
              '',
              '',
              '',
              _fecha_inicio_objetivo,
              _hora_inicio_objetivo,
              _fecha_fin_objetivo,
              _hora_fin_objetivo,
              _id_objetivo);
        }

        //comentario
        if (_jobs[i]['nombreelemento'] == 'Comentario') {
          await SQLHelper.saveEntregable(
              _id_rol,
              'Comentario',
              _job_comentario.text,
              '',
              '',
              '',
              '',
              '',
              _fecha_inicio_objetivo,
              _hora_inicio_objetivo,
              _fecha_fin_objetivo,
              _hora_fin_objetivo,
              _id_objetivo);
        }

        //foto
        if (_jobs[i]['nombreelemento'] == 'Foto') {
          /*
          //convertimos a base64
          String imagepath = pickedPhoto!.path;
          File imagefile = File(imagepath); //convert Path to File
          Uint8List imagebytes =
              await imagefile.readAsBytes(); //convert to bytes
          String base64string =
              base64.encode(imagebytes); //convert bytes to base64 string
              */
          //print(base64string);

          await SQLHelper.saveEntregable(
              _id_rol,
              'Foto',
              '',
              '',
              '',
              '',
              _job_foto.text,
              '',
              _fecha_inicio_objetivo,
              _hora_inicio_objetivo,
              _fecha_fin_objetivo,
              _hora_fin_objetivo,
              _id_objetivo);
        }

        //cantidad
        if (_jobs[i]['nombreelemento'] == 'Cantidad') {
          await SQLHelper.saveEntregable(
              _id_rol,
              'Cantidad',
              '',
              _job_cantidad.text,
              '',
              '',
              '',
              '',
              _fecha_inicio_objetivo,
              _hora_inicio_objetivo,
              _fecha_fin_objetivo,
              _hora_fin_objetivo,
              _id_objetivo);
        }

        //audio
        if (_jobs[i]['nombreelemento'] == 'Audio') {
          /*Uint8List? fileBytes = pickedFile!.files.first.bytes;
          var mimType = lookupMimeType(pickedFile!.files.first.name,
            headerBytes: pickedFile!.files.first.bytes);
          var uri = Uri.dataFromBytes(fileBytes!, mimeType: mimType!).toString();
          print(uri);
          */

          String? filepath = pickedFile!.files.first.path;

          await SQLHelper.saveEntregable(
              _id_rol,
              'Audio',
              '',
              '',
              '',
              '',
              '',
              filepath,
              _fecha_inicio_objetivo,
              _hora_inicio_objetivo,
              _fecha_fin_objetivo,
              _hora_fin_objetivo,
              _id_objetivo);
        }

        //hora
        if (_jobs[i]['nombreelemento'] == 'Hora') {
          await SQLHelper.saveEntregable(
              _id_rol,
              'Hora',
              '',
              '',
              '',
              _job_hora.text,
              '',
              '',
              _fecha_inicio_objetivo,
              _hora_inicio_objetivo,
              _fecha_fin_objetivo,
              _hora_fin_objetivo,
              _id_objetivo);
        }
      }

      if (_firma_objetivo == 'Si') {
        await SQLHelper.saveEntregable(
            _id_rol,
            'Firma',
            '',
            '',
            '',
            '',
            _job_firma.text,
            '',
            _fecha_inicio_objetivo,
            _hora_inicio_objetivo,
            _fecha_fin_objetivo,
            _hora_fin_objetivo,
            _id_objetivo);
      }

      if (_codigoqr_objetivo == 'Si') {
        await SQLHelper.saveEntregable(
            _id_rol,
            'QR',
            _job_codigoqr.text,
            '',
            '',
            '',
            '',
            '',
            _fecha_inicio_objetivo,
            _hora_inicio_objetivo,
            _fecha_fin_objetivo,
            _hora_fin_objetivo,
            _id_objetivo);
      }

      await SQLHelper.updateWithRealizadoObjetivoMarca(_id_objetivo_marca!)
          .then((value) {
        final route = MaterialPageRoute(builder: (context) {
          return Targets();
        });
        Navigator.push(context, route);
      });
    } else {
      allJobsFinished = true;
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) =>
              AttentionDialog(content: unfinishedJobsMessage.toString()));
    }
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

  Future getAudioFile() async {
    pickedFile = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (pickedFile != null) {
      PlatformFile file = pickedFile!.files.first;
      setState(() {
        _job_audio.text = file.path!;
      });
      /*print(file.name);
      print(file.bytes);
      print(file.size);
      print(file.extension);
      print(file.path);
      */
    } else {
      // User canceled the picker
    }
  }

  Future<String> _createFileFromString(encodedStr) async {
    Uint8List bytes = base64.decode(encodedStr);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File(
        "$dir/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg");
    //File file = File("$dir/firma.jpg");
    await file.writeAsBytes(bytes);
    return file.path;
  }

  getSignature() {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        enableDrag: false,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SafeArea(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (signatureBytes != null)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 10),
                                Container(
                                  height: size.width / 2,
                                  width: size.width / 1.5,
                                  child: Image.memory(
                                    signatureBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text("Firma guardada"),
                              ],
                            ),
                          Divider(),
                          Text("Firma"),
                          EasySignaturePad(
                            onChanged: (image) {
                              setImage(image);
                            },
                            height: size.width ~/ 2,
                            width: size.width ~/ 1.5,
                            penColor: Colors.black,
                            strokeWidth: 2.0,
                            borderRadius: 10.0,
                            borderColor: Colors.black,
                            backgroundColor: Colors.white,
                            transparentImage: false,
                            transparentSignaturePad: false,
                            hideClearSignatureIcon: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: FlatTextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      edgeInsetsPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                      color: Color(0xff111c43),
                      text: Text(
                        'GUARDAR',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          });
        });
  }

  Future<void> getQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancelar', false, ScanMode.QR);

      //print("Codigo:"+barcodeScanRes);

      if (barcodeScanRes.toString() != '-1') {
        _job_codigoqr.text = barcodeScanRes.toString();
      }
    } on PlatformException {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(
              content: "No se pudo obtener la versión de la plataforma."));

      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void setImage(String bytes) async {
    if (bytes.isNotEmpty) {
      Uint8List convertedBytes = base64Decode(bytes);

      //guardamos el archivo
      final firmafile = await _createFileFromString(bytes);

      setState(() {
        //guardamos el path del archivo guardado
        _job_firma.text = firmafile.toString();
        signatureBytes = convertedBytes;
      });
    } else {
      setState(() {
        signatureBytes = null;
      });
    }
  }

  _tempSaveFecha() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('_job_fecha$_id_rol', _job_fecha.text);
  }

  _tempSaveComentario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('_job_comentarioSaved$_id_rol', _job_comentario.text);
  }

  _tempSaveCantidad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('_job_cantidadSaved$_id_rol', _job_cantidad.text);
  }

  _tempSaveHora() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('_job_horaSaved$_id_rol', _job_hora.text);
  }

  _tempSaveFoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('_job_fotoSaved$_id_rol', _job_foto.text);
  }

  _tempSaveFirma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('_job_firmaSaved$_id_rol', _job_firma.text);
  }

  _tempSaveQR() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('_job_codigoqrSaved$_id_rol', _job_codigoqr.text);
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
          "Visita Técnica",
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
                SizedBox(
                  height: 30.0,
                ),

                _jobs.length > 0
                    ? Container(
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _jobs.length,
                            itemBuilder: (context, index) {
                              var Mission = _jobs[index];
                              return Column(
                                children: [
                                  if (Mission['nombreelemento'] == 'Fecha') ...[
                                    TextField(
                                      controller: _job_fecha,
                                      decoration: InputDecoration(
                                          icon: Icon(Icons.calendar_today),
                                          labelText: "Selecciona una fecha"),
                                      readOnly: true,
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime(1950),
                                                lastDate: DateTime(2100));
                                        if (pickedDate != null) {
                                          _job_fecha.text =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                        }
                                      },
                                    ),
                                  ],
                                  if (Mission['nombreelemento'] ==
                                      'Comentario') ...[
                                    TextField(
                                      controller: _job_comentario,
                                      decoration: InputDecoration(
                                          icon: Icon(Icons
                                              .comment), //icon of text field
                                          labelText:
                                              "Escribe un comentario" //label text of field
                                          ),
                                    ),
                                  ],
                                  if (Mission['nombreelemento'] == 'Foto') ...[
                                    TextField(
                                      controller: _job_foto,
                                      decoration: InputDecoration(
                                          icon: Icon(Icons.photo),
                                          labelText: "Toma una foto"),
                                      readOnly: true,
                                      onTap: () async {
                                        getPhoto();
                                      },
                                    ),
                                  ],
                                  if (Mission['nombreelemento'] ==
                                      'Cantidad') ...[
                                    TextField(
                                      controller: _job_cantidad,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          icon: Icon(Icons
                                              .numbers), //icon of text field
                                          labelText:
                                              "Escribe una cantidad" //label text of field
                                          ),
                                    ),
                                  ],
                                  if (Mission['nombreelemento'] == 'Audio') ...[
                                    TextField(
                                      controller: _job_audio,
                                      decoration: InputDecoration(
                                          icon: Icon(Icons.speaker),
                                          labelText: "Selecciona una audio"),
                                      readOnly: true,
                                      onTap: () async {
                                        getAudioFile();
                                      },
                                    ),
                                  ],
                                  if (Mission['nombreelemento'] == 'Hora') ...[
                                    TextField(
                                      controller: _job_hora,
                                      decoration: InputDecoration(
                                          icon: Icon(Icons.timer),
                                          labelText: "Selecciona una hora"),
                                      readOnly: true,
                                      onTap: () async {
                                        TimeOfDay? time = await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now());

                                        if (time != null) {
                                          //_job_hora.text = "${time.hour}:${time.minute}";
                                          _job_hora.text = time.format(context);
                                        }
                                      },
                                    ),
                                  ],
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
                              Text("No existen tareas a realizar"),
                            ],
                          ),
                        ),
                      ),
                //FIRMA
                if (_firma_objetivo == 'Si') ...[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                      controller: _job_firma,
                      decoration: InputDecoration(
                          icon: Icon(Icons.create), labelText: "Haz tu Firma"),
                      readOnly: true,
                      onTap: () async {
                        getSignature();
                      },
                    ),
                  ),
                ],

                if (_codigoqr_objetivo == 'Si') ...[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40),
                    child: TextField(
                      controller: _job_codigoqr,
                      decoration: InputDecoration(
                          icon: Icon(Icons.settings_overscan),
                          labelText: "Escanea el código QR"),
                      readOnly: true,
                      onTap: () async {
                        getQR();
                      },
                    ),
                  ),
                ],

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
                      'ENTREGAR FORMULARIO',
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

      bottomNavigationBar: MenuInferior(btn1: 1, btn2: 1, btn3: 2, btn4: 2),
    );
  }
}
