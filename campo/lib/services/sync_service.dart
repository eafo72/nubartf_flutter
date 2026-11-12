import 'api.dart';
import 'local_db.dart';

/// Reenvía lo capturado sin señal. Se llama al abrir la app, al recuperar
/// conexión y al entrar a la lista de misiones.
class SyncService {
  static Future<int>? _sincronizacionEnCurso;

  static Future<int> enviarPendientes() async {
    return _sincronizacionEnCurso ??= _enviarPendientes().whenComplete(() {
      _sincronizacionEnCurso = null;
    });
  }

  static Future<int> _enviarPendientes() async {
    if (!Api.conectado) return 0;
    final pendientes = await LocalDb.cola();
    if (pendientes.isEmpty) return 0;

    var enviados = 0;
    for (final p in pendientes) {
      try {
        await _reenviar(p);
        await LocalDb.borrarPendiente(p.id);
        enviados += 1;
      } on ApiError {
        // Conserva el registro para que no se pierda si el servidor lo rechaza
        // temporalmente o el usuario debe corregirlo desde el panel.
        break;
      }
    }

    if (enviados > 0) {
      try {
        await Api.registrarSincronizacion(enviados);
      } on ApiError catch (_) {
        // La bitácora es informativa: si falla, los registros ya se enviaron.
      }
    }
    return enviados;
  }

  static Future<void> _reenviar(Pendiente p) async {
    switch (p.tipo) {
      case 'guardar':
        await Api.guardarMisionRemoto(p.misionId, p.payload);
        break;
      case 'entregable':
        await Api.entregableRemoto(p.misionId, p.payload);
        break;
      default:
        throw ApiError('Tipo de registro pendiente no compatible.');
    }
  }
}