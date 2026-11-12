import 'package:flutter/material.dart';

import '../tema.dart';

/// Tarjeta base de la app: fondo blanco, esquina redondeada y borde tenue.
/// Se usa en lugar de [Card] para no depender del tema de tarjetas de cada
/// versión de Flutter.
class Tarjeta extends StatelessWidget {
  final Widget child;
  final Clip clipBehavior;

  const Tarjeta({super.key, required this.child, this.clipBehavior = Clip.none});

  @override
  Widget build(BuildContext context) {
    final radio = BorderRadius.circular(18);
    return Container(
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radio,
        border: Border.all(color: Tema.borde),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radio,
        child: child,
      ),
    );
  }
}