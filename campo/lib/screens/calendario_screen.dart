import 'package:flutter/material.dart';

import '../models.dart';
import '../tema.dart';
import '../util/fechas.dart';
import '../widgets/mapa_mision_dialog.dart';
import '../widgets/mision_card.dart';
import '../widgets/tarjeta.dart';
import 'mision_detalle_screen.dart';

class CalendarioScreen extends StatefulWidget {
  final List<Mision> misiones;

  const CalendarioScreen({super.key, required this.misiones});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  late DateTime _mes;
  late DateTime _seleccionado;
  String _filtro = 'proximas';

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _mes = DateTime(hoy.year, hoy.month);
    _seleccionado = DateTime(hoy.year, hoy.month, hoy.day);
  }

  List<Mision> get _filtradas {
    final hoy = hoyIso();
    if (_filtro == 'pasadas') {
      return widget.misiones.where((m) => m.fechaProgramada.compareTo(hoy) < 0).toList()
        ..sort((a, b) => b.fechaProgramada.compareTo(a.fechaProgramada));
    }
    return widget.misiones.where((m) => m.fechaProgramada.compareTo(hoy) >= 0).toList()
      ..sort((a, b) => a.fechaProgramada.compareTo(b.fechaProgramada));
  }

  List<Mision> _delDia(DateTime dia) {
    final iso = fechaIso(dia);
    final lista = _filtradas.where((m) => m.fechaProgramada == iso).toList();
    lista.sort((a, b) => a.horaProgramada.compareTo(b.horaProgramada));
    return lista;
  }

  void _moverMes(int delta) {
    setState(() => _mes = DateTime(_mes.year, _mes.month + delta));
  }

  Color _colorDia(DateTime dia) {
    final lista = _delDia(dia);
    if (lista.isEmpty) return Tema.borde;
    switch (lista.first.status) {
      case 'entregada':
      case 'completada':
        return Tema.verde;
      case 'en_curso':
        return const Color(0xFF0284C7);
      case 'pausada':
        return const Color(0xFFB45309);
      case 'cancelada':
        return const Color(0xFFBE123C);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final diasEnMes = DateTime(_mes.year, _mes.month + 1, 0).day;
    final desplazamiento = DateTime(_mes.year, _mes.month, 1).weekday - 1;
    final celdas = <Widget>[];
    for (var i = 0; i < desplazamiento; i += 1) {
      celdas.add(const SizedBox.shrink());
    }
    for (var dia = 1; dia <= diasEnMes; dia += 1) {
      final fecha = DateTime(_mes.year, _mes.month, dia);
      final esHoy = fechaIso(fecha) == hoyIso();
      final activo = fechaIso(fecha) == fechaIso(_seleccionado);
      final tiene = _delDia(fecha).isNotEmpty;
      celdas.add(
        GestureDetector(
          onTap: () => setState(() => _seleccionado = fecha),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: activo ? Tema.navy : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dia',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: esHoy || activo ? FontWeight.w800 : FontWeight.w500,
                    color: activo
                        ? Colors.white
                        : (esHoy ? Tema.verdeOscuro : Tema.texto),
                  ),
                ),
                const SizedBox(height: 3),
                if (tiene)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: activo ? Tema.verde : _colorDia(fecha),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final delDia = _delDia(_seleccionado);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario', style: TextStyle(fontSize: 16))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Tarjeta(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _moverMes(-1),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          mesTitulo(_mes),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Tema.texto,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _moverMes(1),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  Row(
                    children: List<Widget>.generate(7, (indice) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            ['L', 'M', 'M', 'J', 'V', 'S', 'D'][indice],
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Tema.tenue,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1,
                    children: celdas,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Chip(
                etiqueta: 'Próximas',
                activo: _filtro == 'proximas',
                onTap: () => setState(() => _filtro = 'proximas'),
              ),
              const SizedBox(width: 8),
              _Chip(
                etiqueta: 'Pasadas',
                activo: _filtro == 'pasadas',
                onTap: () => setState(() => _filtro = 'pasadas'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            fechaLarga(_seleccionado).toUpperCase(),
            style: const TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: Tema.tenue,
            ),
          ),
          const SizedBox(height: 8),
          if (delDia.isEmpty)
            const Tarjeta(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 26),
                child: Column(
                  children: [
                    Icon(Icons.event_available_outlined, size: 28, color: Tema.borde),
                    SizedBox(height: 8),
                    Text(
                      'No hay misiones en esta fecha.',
                      style: TextStyle(fontSize: 12.5, color: Tema.tenue),
                    ),
                  ],
                ),
              ),
            )
          else
            ...delDia.map(
              (mision) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MisionCard(
                  mision: mision,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => MisionDetalleScreen(misionId: mision.id),
                      ),
                    );
                  },
                  onMapa: () => MapaMisionDialog.mostrar(context, mision),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String etiqueta;
  final bool activo;
  final VoidCallback onTap;

  const _Chip({
    required this.etiqueta,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? Tema.navy : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: activo ? Tema.navy : Tema.borde),
        ),
        child: Text(
          etiqueta,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: activo ? Colors.white : Tema.tenue,
          ),
        ),
      ),
    );
  }
}