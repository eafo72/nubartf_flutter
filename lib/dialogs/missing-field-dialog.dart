import 'package:flutter/material.dart';

class MissingFieldsDialog extends StatelessWidget {
  const MissingFieldsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Atención"),
      content: Text("Todos o alguno de los campos están vacíos, por favor revisa e inténtalo de nuevo."),
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xff111c43)),
          ), 
          child: Text(
            "CERRAR",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
