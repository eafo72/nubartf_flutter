import 'package:flutter/material.dart';

import '../models.dart';
import '../tema.dart';
import '../util/fechas.dart';
import 'estado_pill.dart';
import 'tarjeta.dart';

class MisionCard extends StatelessWidget {
  final Mision mision;
  final VoidCallback onTap;
  final VoidCallback onMapa;

  const MisionCard({
    super.key,
    required this.mision,
    required this.onTap,
    required this.onMapa,
  });

  @override
  Widget build(BuildContext context) {
    final m = mision;
    return Tarjeta(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.clienteNombre.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10.5,
                            letterSpacing: 0.6,
                            fontWeight: FontWeight.w700,
                            color: Tema.tenue,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          m.titulo,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: Tema.texto,
                            height: 1.25,
                          ),
                        ),
                        if (m.tipo.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF7E6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              m.tipo,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Tema.verdeOscuro,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  EstadoPill(status: m.status),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 15, color: Tema.borde),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      m.direccion.isEmpty
                          ? (m.ciudad.isEmpty ? 'Sin dirección registrada' : m.ciudad)
                          : m.direccion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Tema.tenue),
                    ),
                  ),
                  if (m.lat != null && m.lng != null)
                    IconButton(
                      onPressed: onMapa,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.map_outlined, size: 18, color: Tema.verde),
                      tooltip: 'Ver en el mapa',
                    ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 15, color: Tema.borde),
                  const SizedBox(width: 6),
                  Text(
                    '${horaCorta(m.horaProgramada)} · ${fechaCorta(m.fechaProgramada)}',
                    style: const TextStyle(fontSize: 12, color: Tema.tenue),
                  ),
                ],
              ),
              if (m.sos) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'ALERTA SOS ACTIVA',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFBE123C),
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      m.checkinHora.isEmpty
                          ? 'Sin check-in'
                          : 'Check-in ${horaCorta(m.checkinHora)}${m.checkoutHora.isEmpty ? '' : ' · Out ${horaCorta(m.checkoutHora)}'}',
                      style: const TextStyle(fontSize: 11.5, color: Tema.tenue),
                    ),
                  ),
                  Text(
                    m.status == 'pendiente' ? 'Iniciar' : 'Abrir',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Tema.verdeOscuro,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 18, color: Tema.verdeOscuro),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}