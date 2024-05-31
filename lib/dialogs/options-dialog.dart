import 'package:flutter/material.dart';

class OptionsDialog extends StatelessWidget {
  final String title;
  final String content;
  final void Function()? onOk;

  const OptionsDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onOk,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content:Text(content),
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Color(0xff111c43)),
          ),
          child: Text(
            "Ok",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: onOk ??
              () {
                Navigator.of(context).pop();
              },
        )
      ],
    );
  }
}
