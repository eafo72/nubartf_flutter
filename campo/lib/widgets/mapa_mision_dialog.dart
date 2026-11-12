import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models.dart';
import '../tema.dart';

/// Mapa con el pin de la tienda de una misión.
class MapaMisionDialog extends StatelessWidget {
  final Mision mision;

  const MapaMisionDialog({super.key, required this.mision});

  static Future<void> mostrar(BuildContext context, Mision mision) {
    return showDialog<void>(
      context: context,
      builder: (_) => MapaMisionDialog(mision: mision),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = mision.lat;
    final lng = mision.lng;
    final destino = (lat != null && lng != null) ? LatLng(lat, lng) : null;

    return AlertDialog(
      title: const Text('Ubicación de la tienda', style: TextStyle(fontSize: 17)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mision.titulo,
            style: const TextStyle(fontWeight: FontWeight.w700, color: Tema.texto),
          ),
          const SizedBox(height: 2),
          Text(
            [mision.direccion, mision.ciudad].where((v) => v.isNotEmpty).join(', '),
            style: const TextStyle(fontSize: 12.5, color: Tema.tenue),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 240,
              width: double.maxFinite,
              child: destino == null
                  ? Container(
                      color: const Color(0xFFF1F5F9),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Esta tienda todavía no tiene coordenadas registradas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: Tema.tenue),
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(target: destino, zoom: 16),
                      markers: {
                        Marker(markerId: const MarkerId('tienda'), position: destino),
                      },
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}