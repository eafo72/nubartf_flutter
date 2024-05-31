import 'package:flutter/material.dart';

class FlatTextButton extends StatelessWidget {
  final Widget? text;
  final Color? color;
  final Color textColor;
  final double borderRadius;
  final double padding;
  final EdgeInsets? edgeInsetsPadding;
  final double fontSize;
  final void Function()? onPressed;

  
  const FlatTextButton(
      {Key? key,
      this.borderRadius = 16,
      this.color,
      this.edgeInsetsPadding,
      this.fontSize = 22,
      this.onPressed,
      this.padding = 16,
      this.text,
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(textColor),
          //shape: MaterialStateProperty.all(StadiumBorder()),
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.all(color),
          padding: MaterialStateProperty.all(
              edgeInsetsPadding ?? EdgeInsets.all(padding))),
      onPressed: onPressed,
      child: text,
    );
  }
}
