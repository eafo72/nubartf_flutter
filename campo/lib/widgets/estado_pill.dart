import 'package:flutter/material.dart';

class EstadoPill extends StatelessWidget {
  final String status;
  const EstadoPill({super.key, required this.status});

  static const Map<String, String> _etiquetas = {
    'pendiente': 'Pendiente',
    'en_curso': 'En curso',
    'pausada': 'Pausada',
    'entregada': 'Entregada',
    'cancelada': 'Cancelada',
    'completada': 'Finalizada',
  };

  static const Map<String, List<int>> _colores = {
    'pendiente': [0xFFF1F5F9, 0xFF475569],
    'en_curso': [0xFFE0F2FE, 0xFF0369A1],
    'pausada': [0xFFFEF3C7, 0xFFB45309],
    'entregada': [0xFFDCFCE7, 0xFF15803D],
    'cancelada': [0xFFFFE4E6, 0xFFBE123C],
    'completada': [0xFFDCFCE7, 0xFF15803D],
  };

  @override
  Widget build(BuildContext context) {
    final clave = status.isEmpty ? 'pendiente' : status;
    final par = _colores[clave] ?? _colores['pendiente']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color(par[0]),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: Color(par[1]), shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _etiquetas[clave] ?? clave,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(par[1]),
            ),
          ),
        ],
      ),
    );
  }
}