import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models.dart';
import '../services/api.dart';
import '../tema.dart';
import '../util/fechas.dart';
import '../widgets/tarjeta.dart';

class ViaticosScreen extends StatefulWidget {
  const ViaticosScreen({super.key});

  @override
  State<ViaticosScreen> createState() => _ViaticosScreenState();
}

class _ViaticosScreenState extends State<ViaticosScreen> {
  List<Viatico> _lista = <Viatico>[];
  List<Mision> _misiones = <Mision>[];
  bool _cargando = true;
  bool _guardando = false;
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
      final viaticos = await Api.viaticos();
      if (!mounted) return;
      setState(() {
        _lista = viaticos;
        _error = null;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
    if (_misiones.isEmpty) {
      try {
        final misiones = await Api.misiones();
        if (mounted) setState(() => _misiones = misiones);
      } on ApiError catch (_) {
        // El selector de misión es opcional.
      }
    }
  }

  String _monto(double valor) {
    final partes = valor.toStringAsFixed(2).split('.');
    final entero = partes[0];
    final buffer = StringBuffer();
    for (var i = 0; i < entero.length; i += 1) {
      if (i > 0 && (entero.length - i) % 3 == 0) buffer.write(',');
      buffer.write(entero[i]);
    }
    return '\$${buffer.toString()}.${partes[1]}';
  }

  Future<void> _nuevo() async {
    final concepto = TextEditingController();
    final monto = TextEditingController();
    final notas = TextEditingController();
    var misionId = '';
    String? comprobante;
    var subiendo = false;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, refrescar) {
          final valido = concepto.text.trim().isNotEmpty &&
              (double.tryParse(monto.text.trim()) ?? 0) > 0;
          return AlertDialog(
            title: const Text('Nuevo viático', style: TextStyle(fontSize: 17)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: concepto,
                    onChanged: (_) => refrescar(() {}),
                    decoration: const InputDecoration(labelText: 'Concepto'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: monto,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => refrescar(() {}),
                    decoration: const InputDecoration(labelText: 'Monto (MXN)'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: misionId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Misión (opcional)'),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Sin misión')),
                      ..._misiones.map(
                        (m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.titulo, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (valor) => refrescar(() => misionId = valor ?? ''),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notas,
                    minLines: 1,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: subiendo
                        ? null
                        : () async {
                            refrescar(() => subiendo = true);
                            final picker = ImagePicker();
                            final foto = await picker.pickImage(
                              source: ImageSource.camera,
                              maxWidth: 1400,
                              imageQuality: 70,
                            );
                            if (foto != null) {
                              final bytes = await foto.readAsBytes();
                              comprobante = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                            }
                            refrescar(() => subiendo = false);
                          },
                    icon: const Icon(Icons.receipt_long_outlined, size: 17),
                    label: Text(comprobante == null ? 'Agregar comprobante' : 'Comprobante listo'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(contexto).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: valido
                    ? () => Navigator.of(contexto).pop(<String, dynamic>{
                          'concepto': concepto.text.trim(),
                          'monto': double.tryParse(monto.text.trim()) ?? 0,
                          'notas': notas.text.trim(),
                          'mision_id': misionId,
                          if (comprobante != null) 'data_url': comprobante,
                        })
                    : null,
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );

    if (resultado == null) return;
    setState(() => _guardando = true);
    try {
      await Api.crearViatico(resultado);
      _avisar('Viático registrado.');
      await _cargar();
    } on ApiError catch (e) {
      _avisar(e.sinConexion
          ? 'Sin conexión. El viático necesita señal para registrarse.'
          : e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _cargar,
          color: Tema.verde,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              const Text(
                'VIÁTICOS',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                  color: Tema.verdeOscuro,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Gastos de la ruta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Tema.texto,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Captura el gasto y su comprobante; tu coordinador lo revisa desde el panel.',
                style: TextStyle(fontSize: 11.5, color: Tema.tenue, height: 1.4),
              ),
              const SizedBox(height: 16),
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
                        Icon(Icons.receipt_long_outlined, size: 28, color: Tema.borde),
                        SizedBox(height: 8),
                        Text(
                          'Todavía no has registrado viáticos.',
                          style: TextStyle(fontSize: 12.5, color: Tema.tenue),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._lista.map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Tarjeta(
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    v.concepto,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Tema.texto,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    [fechaCorta(v.fecha), v.misionTitulo]
                                        .where((t) => t.isNotEmpty)
                                        .join(' · '),
                                    style: const TextStyle(fontSize: 11.5, color: Tema.tenue),
                                  ),
                                  if (v.notas.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        v.notas,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, color: Tema.tenue),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _monto(v.monto),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Tema.navy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  v.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: v.status == 'aprobado'
                                        ? const Color(0xFF15803D)
                                        : (v.status == 'rechazado'
                                            ? const Color(0xFFBE123C)
                                            : const Color(0xFFB45309)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _guardando ? null : _nuevo,
            backgroundColor: Tema.navy,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo viático'),
          ),
        ),
      ],
    );
  }
}