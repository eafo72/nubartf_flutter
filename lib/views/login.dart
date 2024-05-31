import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/loading-dialog.dart';
import '../dialogs/missing-field-dialog.dart';
import '../dialogs/successful-dialog.dart';
import '../dialogs/attention-dialog.dart';

import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../shared/buttons.dart';

import '../widgets/menu_inferior.dart';

import 'home.dart';

class Login extends StatefulWidget {
  static const String routeName = 'login';

  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool loading = false;

  bool _isObscure = true;

  String _tipo_usuario = " ";

  final TextEditingController _NombreUsuarioController =
      TextEditingController();
  final TextEditingController _PasswordController = TextEditingController();

  Future performCredentialsLogin(context) async {
    if (!(_NombreUsuarioController.text != '') ||
        !(_PasswordController.text != '')) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => MissingFieldsDialog());
      return;
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LoadingDialog());

    verifyUser(
        _NombreUsuarioController.text, _PasswordController.text, context);

    _NombreUsuarioController.text = '';
    _PasswordController.text = '';
  }

  Future verifyUser(String _username, String _passw, context) async {
    /* Verify user in api */
    return LoginUsuario(_username, _passw).then((event) async {
      //print(event['0']);

      bool error = event['error'];
      String mensaje = event['mensaje'];

      if (error == false) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id_usuario', int.parse(event['0']['id_usuario']));
        await prefs.setString('nombre_usuario', event['0']['nombre_usuario']);
        await prefs.setString(
            'direccion_usuario', event['0']['direccion_usuario']);
        await prefs.setString('foto_usuario', event['0']['foto_usuario']);
        await prefs.setBool('logged', true);
        await prefs.setBool('keepSavingGPS', false);
        await prefs.setString('generalStatus', 'play');

        await prefs.setString('last_nav_position', "login");

        //envia a inicio
        final route = MaterialPageRoute(builder: (context) {
          return Home();
        });
        Navigator.push(context, route);
      } else {
        Navigator.of(context).pop(); //cerramos el loading
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AttentionDialog(content: mensaje));
      }
    }).catchError((onError) {
      Navigator.of(context).pop();
      //mensaje de error
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(content: onError.toString()));
      /* builder: (_) => AttentionDialog(content: "Datos incorrectos"));*/
    });
  }

  Future<dynamic> LoginUsuario(String _username, String _passw) async {
    //API
    String url1 =
        '${ServerInformation.API_ROOT}/usuario.php?opcion=1&username=${_username}&password=${_passw}';
    var response1 = await Dio().get(
      url1,
      options: Options(
        headers: {
          'Apikey': '${Secret.secretID}',
        },
      ),
    );
    final data1 = response1.data;
    if (data1 != null) {
      //print(data1);
      return data1;
    }
  }

  //LOADING
  setLoading(bool valor) {
    setState(() {
      loading = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff111c43),
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
            image: AssetImage('assets/img/rtf_logo_light.png'),
          ),
        ),
        toolbarHeight: 70,
        excludeHeaderSemantics: true,
        automaticallyImplyLeading: false,
      ),
      //drawer: MenuWidget(),
      body: (loading == true)
          ? LoadingDialog()
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/fondo2.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                primary: true,
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.15,
                    ),
                    Container(
                      height: size.height * 0.85,
                      padding: EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4.0)),
                        //border: Border.all(color: Color(0xffa2a2a2)),
                      ),
                      child: Column(
                        children: [
                          //Contactanos
                          Center(
                            child: Text("Bienvenido",
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text(
                            'Por favor, ingrese sus datos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),

                          TextFormField(
                            keyboardType: TextInputType.text,
                            controller: _NombreUsuarioController,
                            decoration: const InputDecoration(
                              floatingLabelStyle: TextStyle(color:Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              label: Text('Ingresa tu nombre de usuario'),
                              labelStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey),
                              enabledBorder: const OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: const BorderSide(
                                    color: Color(0xFFa7a7a7), width: 0.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0))),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            keyboardType: TextInputType.text,
                            controller: _PasswordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                              floatingLabelStyle: TextStyle(color:Colors.black),
                              filled: true,
                              fillColor: Colors.white,
                              label: Text('Ingresa tu contraseña'),
                              labelStyle: TextStyle(
                                  fontSize: 16, color: Colors.grey),
                              enabledBorder: const OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: const BorderSide(
                                    color: Color(0xFFa7a7a7), width: 0.0),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4.0))),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),

                          SizedBox(
                            height: 30.0,
                          ),

                          Container(
                            width: double.infinity,
                            child: FlatTextButton(
                              onPressed: () {
                                performCredentialsLogin(context);
                              },
                              color: Color(0xff111c43),
                              text: Text(
                                'ENTRAR',
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
