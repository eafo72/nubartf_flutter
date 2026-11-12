import 'package:flutter/material.dart';

import 'config.dart';
import 'screens/login_screen.dart';
import 'screens/shell.dart';
import 'services/api.dart';
import 'tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.cargarSesion();
  runApp(const RtfCampoApp());
}

class RtfCampoApp extends StatelessWidget {
  const RtfCampoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.appNombre,
      debugShowCheckedModeBanner: false,
      navigatorKey: navegadorLlave,
      theme: Tema.tema,
      initialRoute: Api.conectado ? '/' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/': (_) => const Shell(),
      },
    );
  }
}