import 'package:flutter/material.dart';

/// Navegación global: la usa el cliente de API para regresar al acceso cuando
/// el servidor invalida la sesión (colaborador desactivado o clave cambiada).
final GlobalKey<NavigatorState> navegadorLlave = GlobalKey<NavigatorState>();

class Config {
  static const String apiBase = 'https://rtf-form-flow.base44.app/functions';

  static Uri uri(String funcion) => Uri.parse('$apiBase/$funcion');

  static const String appNombre = 'RTF 2.0';
}