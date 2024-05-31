import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:cell_calendar/cell_calendar.dart';

import '../config/constants.dart';
import '../dialogs/loading-dialog.dart';
import '../shared/buttons.dart';
import '../widgets/menu_inferior_home.dart';
import 'daydetails.dart';
import 'login.dart';

import '../sqlhelper.dart';

class Program extends StatefulWidget {
  static const String routeName = 'program';

  Program({Key? key}) : super(key: key);

  @override
  State<Program> createState() => _ProgramState();
}

class _ProgramState extends State<Program> {
  bool loading = false;

  bool? _logged;

  int? _id_usuario;

  DateTime? _dateSelected;

  List<Map<String, dynamic>> _rolesNext = [];

  List<CalendarEvent> events = [];

  Future cargarData() async {
    setLoading(true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id_usuario = prefs.getInt('id_usuario');
    _logged = prefs.getBool('logged');

    await prefs.setString('last_nav_position', "program");

    setState(() {});

    if (_logged != true) {
      final route = MaterialPageRoute(builder: (context) {
        return Login();
      });
      Navigator.push(context, route);
    }

    //todos los roles proximos
    final data = await SQLHelper.getNextRoles();
    _rolesNext = data;

    for (int i = 0; i < _rolesNext.length; i++) {
      events.add(
        CalendarEvent(
          eventID: _rolesNext[i]['rolmaestroid'].toString(),
          eventName: _rolesNext[i]['nombretienda'],
          eventDate: DateTime.parse(_rolesNext[i]['fechaprogramadavisitarol'] +
              " " +
              _rolesNext[i]['horaprogramadavisitarol']),
          eventBackgroundColor: Colors.purple,
          eventTextStyle: TextStyle(
            fontSize: 9,
            color: Colors.white,
          ),
        ),
      );
    }

    setState(() {});

    setLoading(false);
  }

  _showDayDetails(date) async {
    //print(date);
    final dayDetails = date.toString().substring(0, 10);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('dayDetails', dayDetails);

    final route = MaterialPageRoute(builder: (context) {
      return DayDetails();
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
    final cellCalendarPageController = CellCalendarPageController();
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
          "Programado",
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
          : CellCalendar(
              cellCalendarPageController: cellCalendarPageController,
              events: events,
              daysOfTheWeekBuilder: (dayIndex) {
                final labels = ["S", "M", "T", "W", "T", "F", "S"];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    labels[dayIndex],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              monthYearLabelBuilder: (datetime) {
                final year = datetime!.year.toString();
                final month = datetime.month.monthName;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Text(
                        "$month  $year",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          cellCalendarPageController.animateToDate(
                            DateTime.now(),
                            curve: Curves.linear,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                      )
                    ],
                  ),
                );
              },
              onCellTapped: (date) {
                //creamos lista con los eventos del dia
                final eventsOnTheDate = events.where((event) {
                  final eventDate = event.eventDate;
                  return eventDate.year == date.year &&
                      eventDate.month == date.month &&
                      eventDate.day == date.day;
                }).toList();
                //si hay eventos en este dia
                if (eventsOnTheDate.length > 0) {
                  _showDayDetails(date);
                }
              },
              onPageChanged: (firstDate, lastDate) {
                /// Called when the page was changed
                /// Fetch additional events by using the range between [firstDate] and [lastDate] if you want
              },
            ),

      bottomNavigationBar: MenuInferiorHome(btn1: 1, btn2: 1, btn3: 1, btn4: 1),
    );
  }
}
