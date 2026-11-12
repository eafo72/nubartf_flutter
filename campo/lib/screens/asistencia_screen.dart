import 'package:flutter/material.dart';

import '../models.dart';
import '../services/api.dart';
import '../services/ubicacion.dart';
import '../tema.dart';
import '../util/fechas.dart';
import '../widgets/tarjeta.dart';

class AsistenciaScreen extends StatefulWidget {
  const AsistenciaScreen({super.key});

  @override
  State<AsistenciaScreen> createState() => _AsistenciaScreenState();
}

class _AsistenciaScreenState extends State<AsistenciaScreen> {
  List<Asistencia> _lista = <Asistencia>[];
  bool _cargando = true;
  bool _registrando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final lista = await Api.asistencias();
      if (!mounted) return;
      setState(() {
        _lista = lista;
        _error = null;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _registrar(String tipo) async {
    setState(() => _registrando = true);
    try {
      final geo = await Ubicacion.actual();
      await Api.registrarAsistencia(
        tipo,
        lat: geo?['lat'],
        lng: geo?['lng'],
        precision: geo?['precision'],
      );
      _avisar(tipo == 'entrada' ? 'Entrada registrada.' : 'Salida registrada.');
      await _cargar();
    } on ApiError catch (e) {
      _avisar(e.sinConexion
          ? 'Sin conexión. La asistencia necesita señal para registrarse.'
          : e.mensaje);
    } finally {
      if (mounted) setState(() => _registrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _cargar,
      color: Tema.verde,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          const Text(
            'JORNADA',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
              color: Tema.verdeOscuro,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            fechaLarga(DateTime.now()),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Tema.texto,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _registrando ? null : () => _registrar('entrada'),
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Entrada'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _registrando ? null : () => _registrar('salida'),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Salida'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Se registra la hora y tu ubicación del momento.',
            style: TextStyle(fontSize: 11.5, color: Tema.tenue),
          ),
          const SizedBox(height: 18),
          const Text(
            'REGISTROS RECIENTES',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: Tema.tenue,
            ),
          ),
          const SizedBox(height: 8),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator(color: Tema.verde)),
            )
          else if (_error != null)
            Tarjeta(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, color: Tema.tenue),
                ),
              ),
            )
          else if (_lista.isEmpty)
            Tarjeta(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 30),
                child: Column(
                  children: const [
                    Icon(Icons.access_time, size: 28, color: Tema.borde),
                    SizedBox(height: 8),
                    Text(
                      'Todavía no registras asistencia hoy.',
                      style: TextStyle(fontSize: 12.5, color: Tema.tenue),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._lista.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Tarjeta(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: a.tipo == 'entrada'
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF1F5F9),
                      child: Icon(
                        a.tipo == 'entrada' ? Icons.login : Icons.logout,
                        size: 18,
                        color: a.tipo == 'entrada' ? const Color(0xFF15803D) : Tema.tenue,
                      ),
                    ),
                    title: Text(
                      '${a.tipo == 'entrada' ? 'Entrada' : 'Salida'} · ${horaCorta(a.hora)}',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      [fechaCorta(a.fecha), a.direccion].where((v) => v.isNotEmpty).join(' · '),
                      style: const TextStyle(fontSize: 11.5, color: Tema.tenue),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}