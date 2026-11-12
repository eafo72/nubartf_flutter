import 'package:flutter/material.dart';

import '../models.dart';
import '../services/api.dart';
import '../services/local_db.dart';
import '../tema.dart';
import '../util/fechas.dart';
import '../widgets/mapa_mision_dialog.dart';
import '../widgets/mision_card.dart';
import '../widgets/tarjeta.dart';
import 'calendario_screen.dart';
import 'mapa_screen.dart';
import 'mision_detalle_screen.dart';

class MisionesScreen extends StatefulWidget {
  final Future<void> Function()? onColaCambio;

  const MisionesScreen({super.key, this.onColaCambio});

  @override
  State<MisionesScreen> createState() => _MisionesScreenState();
}

class _MisionesScreenState extends State<MisionesScreen> {
  List<Mision> _misiones = <Mision>[];
  bool _cargando = true;
  bool _sinConexion = false;
  String? _error;
  String _vista = 'hoy';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  List<Mision> _ordenar(List<Mision> lista) {
    final copia = List<Mision>.from(lista);
    copia.sort((a, b) {
      final porFecha = b.fechaProgramada.compareTo(a.fechaProgramada);
      if (porFecha != 0) return porFecha;
      return a.horaProgramada.compareTo(b.horaProgramada);
    });
    return copia;
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final lista = await Api.misiones();
      await LocalDb.guardarMisiones(lista);
      if (!mounted) return;
      setState(() {
        _misiones = _ordenar(lista);
        _sinConexion = false;
        _error = null;
      });
    } on ApiError catch (e) {
      final guardadas = await LocalDb.misionesGuardadas();
      if (!mounted) return;
      if (guardadas.isEmpty) {
        setState(() => _error = e.mensaje);
      } else {
        setState(() {
          _misiones = _ordenar(guardadas);
          _sinConexion = true;
          _error = null;
        });
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _abrir(Mision mision) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MisionDetalleScreen(misionId: mision.id),
      ),
    );
    await _cargar();
    await widget.onColaCambio?.call();
  }

  void _abrirCalendario() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CalendarioScreen(misiones: _misiones)),
    );
  }

  void _abrirMapa() {
    final hoy = hoyIso();
    final delDia = _misiones.where((m) => m.fechaProgramada == hoy).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MapaScreen(misiones: delDia, titulo: 'Misiones de hoy'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hoy = hoyIso();
    final delDia = _misiones.where((m) => m.fechaProgramada == hoy).toList();
    final lista = _vista == 'hoy' ? delDia : _misiones;
    final entregadas = lista.where((m) => m.status == 'entregada').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HOLA, VISITADOR',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
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
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      lista.isEmpty
                          ? 'No tienes misiones asignadas.'
                          : '$entregadas de ${lista.length} misiones entregadas.',
                      style: const TextStyle(fontSize: 12, color: Tema.tenue),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AccesoBoton(
                    icono: Icons.calendar_month,
                    etiqueta: 'Calendario',
                    onTap: _abrirCalendario,
                  ),
                  const SizedBox(height: 6),
                  _AccesoBoton(
                    icono: Icons.map_outlined,
                    etiqueta: 'Mapa de hoy',
                    onTap: _abrirMapa,
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Tema.borde),
            ),
            child: Row(
              children: [
                _Pestana(
                  etiqueta: 'Hoy (${delDia.length})',
                  activa: _vista == 'hoy',
                  onTap: () => setState(() => _vista = 'hoy'),
                ),
                _Pestana(
                  etiqueta: 'Todas (${_misiones.length})',
                  activa: _vista == 'todas',
                  onTap: () => setState(() => _vista = 'todas'),
                ),
              ],
            ),
          ),
        ),
        if (_sinConexion)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Sin conexión · mostrando lo guardado en el dispositivo.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB45309),
                ),
              ),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _cargar,
            color: Tema.verde,
            child: _cargando
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      Center(child: CircularProgressIndicator(color: Tema.verde)),
                    ],
                  )
                : _error != null
                    ? _Mensaje(
                        icono: Icons.warning_amber_rounded,
                        titulo: _error!,
                        texto: 'Revisa tu conexión. Lo que registres sin señal se guarda en el teléfono.',
                      )
                    : lista.isEmpty
                        ? const _Mensaje(
                            icono: Icons.assignment_outlined,
                            titulo: 'Sin misiones para hoy',
                            texto: 'Tu coordinador te asignará misiones en cuanto estén listas.',
                          )
                        : ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                            itemCount: lista.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (contexto, indice) {
                              final mision = lista[indice];
                              return MisionCard(
                                mision: mision,
                                onTap: () => _abrir(mision),
                                onMapa: () => MapaMisionDialog.mostrar(contexto, mision),
                              );
                            },
                          ),
          ),
        ),
      ],
    );
  }
}

class _AccesoBoton extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final VoidCallback onTap;

  const _AccesoBoton({
    required this.icono,
    required this.etiqueta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Tema.borde),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 15, color: Tema.verde),
              const SizedBox(width: 5),
              Text(
                etiqueta,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Tema.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  final String etiqueta;
  final bool activa;
  final VoidCallback onTap;

  const _Pestana({
    required this.etiqueta,
    required this.activa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: activa ? Tema.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            etiqueta,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: activa ? Colors.white : Tema.tenue,
            ),
          ),
        ),
      ),
    );
  }
}

class _Mensaje extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String texto;

  const _Mensaje({
    required this.icono,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
      children: [
        Tarjeta(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
            child: Column(
              children: [
                Icon(icono, size: 32, color: Tema.borde),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Tema.texto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texto,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Tema.tenue, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}