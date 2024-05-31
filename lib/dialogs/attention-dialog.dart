import 'package:flutter/material.dart';

class AttentionDialog extends StatelessWidget {
  final String content;
  const AttentionDialog({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Atención"),
      content: Text(content),
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