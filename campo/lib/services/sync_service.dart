import 'api.dart';
import 'local_db.dart';

/// Reenvía lo capturado sin señal. Se llama al abrir la app, al recuperar
/// conexión y al entrar a la lista de misiones.
class SyncService {
  static Future<int> enviarPendientes() async {
    if (!Api.conectado) return 0;
    final pendientes = await LocalDb.cola();
    if (pendientes.isEmpty) return 0;

    var enviados = 0;
    for (final p in pendientes) {
      try {
        await _reenviar(p);
        await LocalDb.borrarPendiente(p.id);
        enviados += 1;
      } on ApiError catch (e) {
        if (e.sinConexion || e.codigo == 401) break;
        // Un registro rechazado por el servidor no debe frenar a los demás.
        await LocalDb.borrarPendiente(p.id);
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
        break;
    }
  }
}