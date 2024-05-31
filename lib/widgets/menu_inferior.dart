import 'package:flutter/material.dart';
import 'package:nubartf/sqlhelper.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/attention-dialog.dart';
import '../shared/buttons.dart';
import '../views/targets.dart';
import '../views/home.dart';
import '../views/profile.dart';
import '../views/shops.dart';

class MenuInferior extends StatefulWidget {
  final int btn1;
  final int btn2;
  final int btn3;
  final int btn4;

  MenuInferior(
      {Key? key,
      required this.btn1,
      required this.btn2,
      required this.btn3,
      required this.btn4})
      : super(key: key);

  @override
  State<MenuInferior> createState() => _MenuInferiorState();
}

class _MenuInferiorState extends State<MenuInferior> {
  bool? _logged;

  int? _idot;
  int? _id_rol;

  int _selectedIndex = 0;

  String? _generalStatus;

  final _sosComentario = TextEditingController();
  String? _selectedTypeOfSOS;
  List<String> _SOSTypes = ['Temblor', 'Simulacro', 'Enfermedad', 'Otro'];

  final _pauseComentario = TextEditingController();
  String? _selectedTypeOfPause;
  List<String> _PauseTypes = ['Comida', 'Malestar', 'Otro'];

  final _playComentario  = TextEditingController();

  cargarData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _logged = prefs.getBool('logged');
    _idot = prefs.getInt('id_ot');
    _id_rol = prefs.getInt('id_rol');
    _generalStatus = prefs.getString('generalStatus');

    setState(() {});
  }

  _showSOS() {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 50,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: Text(
                      "Salir por causas de fuerza mayor",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: DropdownButton<String>(
                      value: _selectedTypeOfSOS,
                      onChanged: (value) {
                        setState(() {
                          _selectedTypeOfSOS = value;
                        });
                      },
                      hint: const Center(
                          child: Text(
                        'Seleccione la Causa',
                        style: TextStyle(color: Colors.black),
                      )),
                      // Hide the default underline
                      underline: Container(),
                      // set the color of the dropdown menu
                      dropdownColor: Color(0xFFe2e2e2),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF8F67E6),
                      ),
                      isExpanded: true,

                      // The list of options
                      items: _SOSTypes.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _sosComentario,
                    decoration: const InputDecoration(hintText: 'Comentario'),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: FlatTextButton(
                      onPressed: () {
                        _goSOS();
                      },
                      edgeInsetsPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                      color: Colors.red,
                      text: Text(
                        'Registrar Salida',
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
            );
          });
        });
  }

  _showPause() {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 50,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: Text(
                      "Poner en pausa",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: DropdownButton<String>(
                      value: _selectedTypeOfPause,
                      onChanged: (value) {
                        setState(() {
                          _selectedTypeOfPause = value;
                        });
                      },
                      hint: const Center(
                          child: Text(
                        'Seleccione la Causa',
                        style: TextStyle(color: Colors.black),
                      )),
                      // Hide the default underline
                      underline: Container(),
                      // set the color of the dropdown menu
                      dropdownColor: Color(0xFFe2e2e2),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Color(0xFF8F67E6),
                      ),
                      isExpanded: true,

                      // The list of options
                      items: _PauseTypes.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _pauseComentario,
                    decoration: const InputDecoration(hintText: 'Comentario'),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: FlatTextButton(
                      onPressed: () {
                        _goPause();
                      },
                      edgeInsetsPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                      color: Colors.red,
                      text: Text(
                        'Registrar Pausa',
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
            );
          });
        });
  }

  _showPlay() {
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 50,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: Text(
                      "Bienvenido de vuelta",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    keyboardType: TextInputType.text,
                    controller: _playComentario,
                    decoration: const InputDecoration(hintText: 'Comentario'),
                  ),
                  SizedBox(height: 30),
                  
                  Center(
                    child: FlatTextButton(
                      onPressed: () {
                        _goPlay();
                      },
                      edgeInsetsPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                      color: Colors.red,
                      text: Text(
                        'Reanudar',
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
            );
          });
        });
  }

  
  _goSOS() async {
    if (_selectedTypeOfSOS == null) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(content: 'Selecciona una causa'));
    } else if (_sosComentario.text == '') {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(content: 'Escribe un comentario'));
    } else {
      //cerramos la mision
      DateTime dateToday = DateTime.now();
      String fecha = dateToday.toString().substring(0, 10);
      String hora = dateToday.toString().substring(11, 19);
      await SQLHelper.abortMissionSOS(_idot!, _id_rol!, _sosComentario.text,
              _selectedTypeOfSOS!, fecha, hora)
          .then((value) {
        final route = MaterialPageRoute(builder: (context) {
          return Home();
        });
        Navigator.push(context, route);
      });
    }
  }

  _goPause() async {
    if (_selectedTypeOfPause == null) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(content: 'Selecciona una causa'));
    } else if (_pauseComentario.text == '') {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AttentionDialog(content: 'Escribe un comentario'));
    } else {
      //pausamos la mision
      DateTime dateToday = DateTime.now();
      String fecha = dateToday.toString().substring(0, 10);
      String hora = dateToday.toString().substring(11, 19);
      await SQLHelper.pauseMission(_idot!, _id_rol!, _pauseComentario.text,_selectedTypeOfPause!, fecha, hora).then((value) async {

        //guardamos el status general
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('generalStatus', 'paused');

        final route = MaterialPageRoute(builder: (context) {
          return Targets();
        });
        Navigator.push(context, route);
       
      });
    }
  }

  
  _goPlay() async {
     //reanudamos la mision
      DateTime dateToday = DateTime.now();
      String fecha = dateToday.toString().substring(0, 10);
      String hora = dateToday.toString().substring(11, 19);
      await SQLHelper.playMission(_idot!, _id_rol!, _playComentario.text, fecha, hora).then((value) async {

        //guardamos el status general
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('generalStatus', 'play');

        final route = MaterialPageRoute(builder: (context) {
          return Targets();
        });
        Navigator.push(context, route);
       
      });
  }
  
  @override
  void initState() {
    super.initState();
    cargarData();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: <BottomNavigationBarItem>[
        if(_generalStatus == 'paused')
        ...[
          BottomNavigationBarItem(
          backgroundColor: Color(0xFFDEE8E8),
          icon: 
          Image(
            image: AssetImage('assets/img/icon6.png'),
            height: 30,
            color: Color(0xFF26bf94),
          ),
          label: 'A',
        ),
        ] else ...[
          BottomNavigationBarItem(
          backgroundColor: Color(0xFFDEE8E8),
          icon: 
          Image(
            image: AssetImage('assets/img/icon5.png'),
            height: 30,
            color: Color(0xFF26bf94),
          ),
          label: 'A',
        ),

        ],
        BottomNavigationBarItem(
          backgroundColor: Color(0xFFDEE8E8),
          icon: Image(
            image: AssetImage('assets/img/icon3.png'),
            height: 30,
            color: Color(0xFFe55c6f),
          ),
          label: 'B',
        ),
        BottomNavigationBarItem(
          backgroundColor: Color(0xFFDEE8E8),
          icon: Image(
            image: AssetImage('assets/img/icon2.png'),
            height: 30,
            color:  widget.btn3 == 1 ? Color(0xFF129fd6) : Colors.grey,
          ),
          label: 'C',
        ),
        BottomNavigationBarItem(
          backgroundColor: Color(0xFFDEE8E8),
          icon: Image(
            image: AssetImage('assets/img/icon1.png'),
            height: 30,
            color: widget.btn4 == 1 ? Color(0xFF845adf) : Colors.grey,
          ),
          label: 'D',
        ),
      ],
      currentIndex: 1,
      selectedItemColor: Color(0xFF00b9a3),
      unselectedItemColor: Color(0xFF00b9a3),
      onTap: _onTap,
    );
  }

  void _onTap(int index) {
    _selectedIndex = index;
    setState(() {});
    if (index == 0 && widget.btn1 == 1 && _generalStatus == 'play'){
      _showPause();
    }
    if (index == 0 && widget.btn1 == 1 && _generalStatus == 'paused'){
      _showPlay();
    }
    if (index == 1 && widget.btn2 == 1) {
      _showSOS();
    }
    if (index == 2 && widget.btn3 == 1) {
      final route = MaterialPageRoute(builder: (context) {
        return Home();
      });
      Navigator.push(context, route);
    }
    if (index == 3 && widget.btn4 == 1) {
      final route = MaterialPageRoute(builder: (context) {
        return Profile();
      });
      Navigator.push(context, route);
    }
  }
}
