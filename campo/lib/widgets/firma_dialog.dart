import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../tema.dart';

/// Firma del cliente dibujada con el dedo. Devuelve una imagen PNG en data URL,
/// que es el formato que ya acepta la API de campo.
class FirmaDialog extends StatefulWidget {
  const FirmaDialog({super.key});

  static Future<String?> abrir(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const FirmaDialog(),
    );
  }

  @override
  State<FirmaDialog> createState() => _FirmaDialogState();
}

class _FirmaDialogState extends State<FirmaDialog> {
  final List<List<Offset>> _trazos = <List<Offset>>[];
  Size _tamano = const Size(300, 180);
  bool _exportando = false;

  Future<String?> _exportar() async {
    if (_trazos.isEmpty) return null;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final area = Offset.zero & _tamano;
    canvas.drawRect(area, Paint()..color = Colors.white);
    final lapiz = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final trazo in _trazos) {
      if (trazo.length == 1) {
        canvas.drawPoints(ui.PointMode.points, trazo, lapiz);
        continue;
      }
      final camino = Path()..moveTo(trazo.first.dx, trazo.first.dy);
      for (final punto in trazo.skip(1)) {
        camino.lineTo(punto.dx, punto.dy);
      }
      canvas.drawPath(camino, lapiz);
    }
    final imagen = await recorder
        .endRecording()
        .toImage(_tamano.width.round(), _tamano.height.round());
    final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    return 'data:image/png;base64,${base64Encode(bytes.buffer.asUint8List())}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Firma del cliente', style: TextStyle(fontSize: 17)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pide al encargado que firme con el dedo.',
            style: TextStyle(fontSize: 12.5, color: Tema.tenue),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Tema.borde),
              borderRadius: BorderRadius.circular(10),
            ),
            child: LayoutBuilder(
              builder: (context, restricciones) {
                _tamano = Size(restricciones.maxWidth, 170);
                return GestureDetector(
                  onPanStart: (detalle) {
                    setState(() => _trazos.add(<Offset>[detalle.localPosition]));
                  },
                  onPanUpdate: (detalle) {
                    if (_trazos.isEmpty) return;
                    setState(() => _trazos.last.add(detalle.localPosition));
                  },
                  child: SizedBox(
                    width: _tamano.width,
                    height: _tamano.height,
                    child: CustomPaint(painter: _PintorFirma(_trazos)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _trazos.isEmpty ? null : () => setState(_trazos.clear),
              icon: const Icon(Icons.undo, size: 16),
              label: const Text('Borrar'),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _exportando ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _exportando || _trazos.isEmpty
              ? null
              : () async {
                  setState(() => _exportando = true);
                  final firma = await _exportar();
                  if (!context.mounted) return;
                  Navigator.of(context).pop(firma);
                },
          child: Text(_exportando ? 'Guardando…' : 'Guardar firma'),
        ),
      ],
    );
  }
}

class _PintorFirma extends CustomPainter {
  final List<List<Offset>> trazos;
  _PintorFirma(this.trazos);

  @override
  void paint(Canvas canvas, Size size) {
    final lapiz = Paint()
      ..color = Tema.navy
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final trazo in trazos) {
      if (trazo.length == 1) {
        canvas.drawPoints(ui.PointMode.points, trazo, lapiz);
        continue;
      }
      final camino = Path()..moveTo(trazo.first.dx, trazo.first.dy);
      for (final punto in trazo.skip(1)) {
        camino.lineTo(punto.dx, punto.dy);
      }
      canvas.drawPath(camino, lapiz);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorFirma anterior) => true;
}