import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models.dart';
import '../tema.dart';
import '../util/fechas.dart';
import 'mision_detalle_screen.dart';

class MapaScreen extends StatefulWidget {
  final List<Mision> misiones;
  final String titulo;

  const MapaScreen({
    super.key,
    required this.misiones,
    this.titulo = 'Misiones del día',
  });

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  Mision? _seleccionada;

  List<Mision> get _conUbicacion =>
      widget.misiones.where((m) => m.lat != null && m.lng != null).toList();

  @override
  Widget build(BuildContext context) {
    final puntos = _conUbicacion;
    final centro = puntos.isNotEmpty
        ? LatLng(puntos.first.lat!, puntos.first.lng!)
        : const LatLng(19.4326, -99.1332);

    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo, style: const TextStyle(fontSize: 16))),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: centro, zoom: 12),
                  markers: puntos
                      .map(
                        (m) => Marker(
                          markerId: MarkerId(m.id),
                          position: LatLng(m.lat!, m.lng!),
                          infoWindow: InfoWindow(title: m.titulo, snippet: m.clienteNombre),
                          onTap: () => setState(() => _seleccionada = m),
                        ),
                      )
                      .toSet(),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                ),
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x1A0F172A), blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Text(
                      '${puntos.length} de ${widget.misiones.length} con ubicación',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Tema.navy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: widget.misiones.isEmpty
                ? const Center(
                    child: Text(
                      'No hay misiones programadas para este día.',
                      style: TextStyle(fontSize: 12.5, color: Tema.tenue),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    itemCount: widget.misiones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (contexto, indice) {
                      final m = widget.misiones[indice];
                      final activa = _seleccionada?.id == m.id;
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() => _seleccionada = m);
                            Navigator.of(contexto).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MisionDetalleScreen(misionId: m.id),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: activa ? Tema.verde : Tema.borde,
                                width: activa ? 1.6 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  m.lat != null ? Icons.place : Icons.place_outlined,
                                  size: 18,
                                  color: m.lat != null ? Tema.verde : Tema.borde,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.titulo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Tema.texto,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${horaCorta(m.horaProgramada)} · ${m.direccion.isEmpty ? m.ciudad : m.direccion}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11.5, color: Tema.tenue),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}