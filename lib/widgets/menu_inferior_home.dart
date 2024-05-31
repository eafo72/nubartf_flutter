import 'package:flutter/material.dart';
import 'package:nubartf/sqlhelper.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../dialogs/attention-dialog.dart';
import '../shared/buttons.dart';
import '../views/home.dart';
import '../views/profile.dart';
import '../views/shops.dart';

class MenuInferiorHome extends StatefulWidget {
  final int btn1;
  final int btn2;
  final int btn3;
  final int btn4;

  MenuInferiorHome(
      {Key? key,
      required this.btn1,
      required this.btn2,
      required this.btn3,
      required this.btn4})
      : super(key: key);

  @override
  State<MenuInferiorHome> createState() => _MenuInferiorHomeState();
}

class _MenuInferiorHomeState extends State<MenuInferiorHome> {
  bool? _logged;
  
  int _selectedIndex = 0;

  cargarData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _logged = prefs.getBool('logged');

    setState(() {});
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
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          backgroundColor: Color(0xFFDEE8E8),
          icon:  Image(
            image: AssetImage('assets/img/icon4.png'),
            height: 30,
            color: Color(0xFF26bf94),
          ),
          label: 'A',
        ),
        /*
        BottomNavigationBarItem(
          backgroundColor: Color(0xFFDEE8E8),
          icon:  Image(
            image: AssetImage('assets/img/icon3.png'),
            height: 30,
          ),
          label: 'B',
        ),
        */
        BottomNavigationBarItem(
          backgroundColor: Color(0xFFDEE8E8),
          icon:  Image(
            image: AssetImage('assets/img/icon2.png'),
            height: 30,
            color: Color(0xFF129fd6),
          ),
          label: 'C',
        ),
        BottomNavigationBarItem(
          backgroundColor: Color(0xFFDEE8E8),
          icon:  Image(
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
    );
  }

  void _onTap(int index) {
    _selectedIndex = index;
    setState(() {});
    if (index == 0 && widget.btn1 == 1) {
      final route = MaterialPageRoute(builder: (context) {
        return Shops();
      });
      Navigator.push(context, route);
    }
    /*
    if (index == 1 && widget.btn2 == 1) {
      //_showSOS();
    }
    */
    if (index == 1 && widget.btn3 == 1) {
      final route = MaterialPageRoute(builder: (context) {
        return Home();
      });
      Navigator.push(context, route);
    }
    if (index == 2 && widget.btn4 == 1) {
      final route = MaterialPageRoute(builder: (context) {
        return Profile();
      });
      Navigator.push(context, route);
    }
  }
}
