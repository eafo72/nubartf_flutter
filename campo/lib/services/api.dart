import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models.dart';
import 'local_db.dart';

class ApiError implements Exception {
  final String mensaje;
  final int codigo;
  final bool sinConexion;

  ApiError(this.mensaje, {this.codigo = 0, this.sinConexion = false});

  @override
  String toString() => mensaje;
}

/// Cliente de la API de campo. La sesión se abre con el usuario y la clave que
/// definió el administrador; el token resultante viaja en cada operación.
class Api {
  static const String _llaveSesion = 'rtf.campo.sesion';

  static String? token;
  static Colaborador? colaborador;

  static bool get conectado => (token ?? '').isNotEmpty;

  static Future<void> cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final crudo = prefs.getString(_llaveSesion);
    if (crudo == null) return;
    try {
      final datos = jsonDecode(crudo);
      if (datos is Map) {
        token = '${datos['token'] ?? ''}';
        colaborador = Colaborador.fromJson(datos['colaborador']);
      }
    } catch (_) {
      token = null;
      colaborador = null;
    }
  }

  static Future<Colaborador> login(String usuario, String clave) async {
    final datos = await _post('campoLogin', {'usuario': usuario, 'clave': clave});
    final nuevoToken = '${datos['token'] ?? ''}';
    if (nuevoToken.isEmpty) throw ApiError('No pudimos abrir tu sesión.');
    final quien = Colaborador.fromJson(datos['colaborador']);
    token = nuevoToken;
    colaborador = quien;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _llaveSesion,
      jsonEncode({'token': nuevoToken, 'colaborador': quien.toJson()}),
    );
    return quien;
  }

  static Future<void> cerrarSesion() async {
    token = null;
    colaborador = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_llaveSesion);
  }

  static Future<void> _sesionVencida() async {
    await cerrarSesion();
    navegadorLlave.currentState?.pushNamedAndRemoveUntil('/login', (ruta) => false);
  }

  static Future<Map<String, dynamic>> _post(
    String funcion,
    Map<String, dynamic> cuerpo,
  ) async {
    http.Response respuesta;
    try {
      respuesta = await http
          .post(
            Config.uri(funcion),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(cuerpo),
          )
          .timeout(const Duration(seconds: 45));
    } on SocketException {
      throw ApiError('Sin conexión. Revisa tu red.', sinConexion: true);
    } on TimeoutException {
      throw ApiError('El servidor tardó demasiado. Intenta de nuevo.', sinConexion: true);
    } catch (_) {
      throw ApiError('Sin conexión. Revisa tu red.', sinConexion: true);
    }

    Map<String, dynamic> datos = <String, dynamic>{};
    if (respuesta.body.isNotEmpty) {
      try {
        final decodificado = jsonDecode(respuesta.body);
        if (decodificado is Map) datos = Map<String, dynamic>.from(decodificado);
      } catch (_) {
        datos = <String, dynamic>{};
      }
    }

    final mensaje = '${datos['error'] ?? ''}';
    if (respuesta.statusCode == 401) {
      throw ApiError(
        mensaje.isEmpty ? 'Tu sesión terminó. Vuelve a ingresar.' : mensaje,
        codigo: 401,
      );
    }
    if (respuesta.statusCode >= 400) {
      throw ApiError(
        mensaje.isEmpty ? 'No pudimos completar la operación. Intenta de nuevo.' : mensaje,
        codigo: respuesta.statusCode,
      );
    }
    if (mensaje.isNotEmpty && mensaje.toLowerCase() != 'false') {
      throw ApiError(mensaje, codigo: respuesta.statusCode);
    }
    return datos;
  }

  static Future<Map<String, dynamic>> _campo(
    String funcion,
    Map<String, dynamic> cuerpo,
  ) async {
    if (!conectado) {
      throw ApiError('Vuelve a ingresar con tu usuario y contraseña.', codigo: 401);
    }
    try {
      return await _post(funcion, {...cuerpo, 'token': token});
    } on ApiError catch (e) {
      if (e.codigo == 401) await _sesionVencida();
      rethrow;
    }
  }

  // --- Misiones -------------------------------------------------------------

  static Future<List<Mision>> misiones() async {
    final datos = await _campo('campoMisiones', {'accion': 'listar'});
    final lista = datos['misiones'];
    if (lista is! List) return <Mision>[];
    return lista
        .map((m) => Mision.fromJson(m))
        .whereType<Mision>()
        .toList();
  }

  static Future<Map<String, dynamic>> misionDetalle(String id) =>
      _campo('campoMisiones', {'accion': 'obtener', 'mision_id': id});

  static Future<Map<String, dynamic>> guardarMisionRemoto(
    String id,
    Map<String, dynamic> cambios,
  ) =>
      _campo('campoMisiones', {
        'accion': 'guardar',
        'mision_id': id,
        'cambios': cambios,
      });

  static Future<Map<String, dynamic>> entregableRemoto(
    String id,
    Map<String, dynamic> datos,
  ) =>
      _campo('campoMisiones', {
        'accion': 'entregable',
        'mision_id': id,
        ...datos,
      });

  /// Guarda la misión; si no hay señal, la deja en la cola del teléfono.
  static Future<Map<String, dynamic>> guardar(
    String id,
    Map<String, dynamic> cambios,
  ) async {
    try {
      return await guardarMisionRemoto(id, cambios);
    } on ApiError catch (e) {
      if (!e.sinConexion) rethrow;
      await LocalDb.encolar('guardar', id, cambios);
      return {'offline': true};
    }
  }

  /// Sube una evidencia (foto o firma en data URL); sin señal queda en cola.
  static Future<Map<String, dynamic>> subirEvidencia(
    String id,
    Map<String, dynamic> datos,
  ) async {
    try {
      return await entregableRemoto(id, datos);
    } on ApiError catch (e) {
      if (!e.sinConexion) rethrow;
      await LocalDb.encolar('entregable', id, datos);
      return {'offline': true};
    }
  }

  /// Señal de ubicación en vivo: si falla no interrumpe al visitador.
  static Future<void> reportarUbicacion(
    String id,
    double lat,
    double lng,
    double? precision,
  ) async {
    try {
      await _campo('campoMisiones', {
        'accion': 'ubicacion',
        'mision_id': id,
        'lat': lat,
        'lng': lng,
        'precision': precision,
      });
    } on ApiError catch (_) {
      // La siguiente señal vuelve a intentarlo.
    }
  }

  // --- Jornada y viáticos ---------------------------------------------------

  static Future<List<Asistencia>> asistencias() async {
    final datos = await _campo('campoOperacion', {'accion': 'asistencias'});
    final lista = datos['asistencias'];
    if (lista is! List) return <Asistencia>[];
    return lista.map(Asistencia.fromJson).whereType<Asistencia>().toList();
  }

  static Future<void> registrarAsistencia(
    String tipo, {
    double? lat,
    double? lng,
    double? precision,
  }) async {
    await _campo('campoOperacion', {
      'accion': 'asistenciaCrear',
      'tipo': tipo,
      'lat': lat,
      'lng': lng,
      'precision': precision,
    });
  }

  static Future<List<Viatico>> viaticos() async {
    final datos = await _campo('campoOperacion', {'accion': 'viaticos'});
    final lista = datos['viaticos'];
    if (lista is! List) return <Viatico>[];
    return lista.map(Viatico.fromJson).whereType<Viatico>().toList();
  }

  static Future<void> crearViatico(Map<String, dynamic> datos) async {
    await _campo('campoOperacion', {'accion': 'viaticoCrear', ...datos});
  }

  static Future<String> llaveMapas() async {
    final datos = await _campo('campoOperacion', {'accion': 'mapa'});
    return '${datos['key'] ?? ''}';
  }

  static Future<void> registrarSincronizacion(int registros) async {
    await _campo('campoOperacion', {
      'accion': 'sincronizar',
      'registros': registros,
      'tipo': 'Cola offline',
      'dispositivo': 'App Flutter',
      'detalle': '$registros registros enviados desde el dispositivo',
    });
  }
}