import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models.dart';
import '../services/api.dart';
import '../services/local_db.dart';
import '../services/ubicacion.dart';
import '../tema.dart';
import '../util/fechas.dart';
import '../widgets/estado_pill.dart';
import '../widgets/firma_dialog.dart';
import '../widgets/mapa_mision_dialog.dart';
import '../widgets/objetivos_panel.dart';
import '../widgets/tarjeta.dart';

class MisionDetalleScreen extends StatefulWidget {
  final String misionId;

  const MisionDetalleScreen({super.key, required this.misionId});

  @override
  State<MisionDetalleScreen> createState() => _MisionDetalleScreenState();
}

class _MisionDetalleScreenState extends State<MisionDetalleScreen> {
  Map<String, dynamic>? _datos;
  List<Entregable> _entregables = <Entregable>[];
  bool _cargando = true;
  bool _guardando = false;
  bool _sinConexion = false;
  String? _error;
  Timer? _senal;
  final TextEditingController _comentario = TextEditingController();
  bool _comentarioIniciado = false;

  Mision? get _mision => _datos == null ? null : Mision(_datos!);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _senal?.cancel();
    _comentario.dispose();
    super.dispose();
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
      final datos = await Api.misionDetalle(widget.misionId);
      final mision = datos['mision'];
      if (mision is! Map) throw ApiError('Misión no encontrada.', codigo: 404);
      final lista = datos['entregables'];
      final entregables = lista is List
          ? lista.map(Entregable.fromJson).whereType<Entregable>().toList()
          : <Entregable>[];
      if (!mounted) return;
      setState(() {
        _datos = Map<String, dynamic>.from(mision);
        _entregables = entregables;
        _sinConexion = false;
        _error = null;
      });
      await LocalDb.guardarMision(Mision(_datos!));
      _iniciarSeguimiento();
    } on ApiError catch (e) {
      final guardada = await LocalDb.misionGuardada(widget.misionId);
      if (!mounted) return;
      if (guardada == null) {
        setState(() => _error = e.codigo == 401 ? e.mensaje : '${e.mensaje}\n\nNo hay copia guardada en el teléfono.');
      } else {
        setState(() {
          _datos = guardada.raw;
          _sinConexion = true;
          _error = null;
        });
        _iniciarSeguimiento();
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _iniciarSeguimiento() {
    if (_comentarioIniciado) return;
    _comentario.text = _mision?.comentario ?? '';
    _comentarioIniciado = true;
    _senal?.cancel();
    _senal = Timer.periodic(const Duration(seconds: 45), (_) => _enviarSenal());
  }

  Future<void> _enviarSenal() async {
    final m = _mision;
    if (m == null || m.status != 'en_curso') return;
    final geo = await Ubicacion.actual();
    if (geo == null) return;
    await Api.reportarUbicacion(m.id, geo['lat']!, geo['lng']!, geo['precision']);
  }

  Future<bool> _guardar(Map<String, dynamic> cambios, {String? exito}) async {
    final m = _mision;
    if (m == null) return false;
    setState(() => _guardando = true);
    try {
      final respuesta = await Api.guardar(m.id, cambios);
      final actual = respuesta['mision'];
      final nuevos = actual is Map ? Map<String, dynamic>.from(actual) : m.fusionar(cambios);
      if (!mounted) return true;
      setState(() => _datos = nuevos);
      await LocalDb.guardarMision(Mision(nuevos));
      final offline = respuesta['offline'] == true;
      _avisar(offline
          ? 'Guardado en el teléfono. Se enviará al recuperar señal.'
          : (exito ?? 'Cambios guardados.'));
      return true;
    } on ApiError catch (e) {
      _avisar(e.mensaje);
      return false;
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<String?> _pedirTexto(
    String titulo,
    String etiqueta, {
    String? hint,
    bool requerido = false,
    int lineas = 1,
  }) async {
    final controlador = TextEditingController();
    final valor = await showDialog<String>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(titulo, style: const TextStyle(fontSize: 17)),
        content: TextField(
          controller: controlador,
          autofocus: true,
          minLines: lineas,
          maxLines: 4,
          decoration: InputDecoration(labelText: etiqueta, hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final escrito = controlador.text.trim();
              if (requerido && escrito.isEmpty) return;
              Navigator.of(contexto).pop(escrito);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    return valor;
  }

  // --- Flujo de la visita ---------------------------------------------------

  Future<void> _checkin() async {
    _avisar('Obteniendo tu ubicación…');
    final geo = await Ubicacion.actual();
    if (geo == null) {
      _avisar('Activa la ubicación del teléfono para hacer check-in.');
      return;
    }
    final ahora = DateTime.now();
    await _guardar({
      'status': 'en_curso',
      'checkin_fecha': hoyIso(),
      'checkin_hora': horaLarga(ahora),
      'checkin_lat': geo['lat'],
      'checkin_lng': geo['lng'],
      'checkin_precision': geo['precision'],
    }, exito: 'Check-in registrado.');
  }

  Future<void> _iniciar() async {
    if (_mision?.requiereCheckin == false) {
      await _guardar({'status': 'en_curso'}, exito: 'Visita iniciada.');
      return;
    }
    await _checkin();
  }

  Future<void> _checkout() async {
    final m = _mision;
    if (m == null) return;
    Map<String, double>? geo;
    if (m.requiereCheckout) {
      geo = await Ubicacion.actual();
      if (geo == null) {
        _avisar('Activa la ubicación del teléfono para hacer check-out.');
        return;
      }
    }
    final respuesta = await _dialogoCheckout();
    if (respuesta == null) return;
    final ahora = DateTime.now();
    await _guardar({
      'status': 'entregada',
      'checkout_fecha': hoyIso(),
      'checkout_hora': horaLarga(ahora),
      'checkout_lat': geo?['lat'],
      'checkout_lng': geo?['lng'],
      'resultado': respuesta['resultado'],
      'comentarios': respuesta['comentarios'],
      'minutos': minutosDesde(m.checkinHora),
      'avance': 100,
    }, exito: 'Visita entregada.');
  }

  Future<Map<String, String>?> _dialogoCheckout() async {
    var resultado = 'completada';
    final controlador = TextEditingController(text: _mision?.comentario ?? '');
    final respuesta = await showDialog<Map<String, String>>(
      context: context,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, refrescar) => AlertDialog(
          title: const Text('Cerrar la visita', style: TextStyle(fontSize: 17)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RESULTADO',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Tema.tenue,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: resultado,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'completada', child: Text('Completada')),
                    DropdownMenuItem(value: 'parcial', child: Text('Parcial')),
                    DropdownMenuItem(value: 'no_realizada', child: Text('No realizada')),
                  ],
                  onChanged: (valor) => refrescar(() => resultado = valor ?? 'completada'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'COMENTARIO DE LA VISITA',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Tema.tenue,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: controlador,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(hintText: '¿Cómo se encontró la tienda?'),
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
              onPressed: () => Navigator.of(contexto).pop({
                'resultado': resultado,
                'comentarios': controlador.text.trim(),
              }),
              child: const Text('Entregar visita'),
            ),
          ],
        ),
      ),
    );
    return respuesta;
  }

  Future<void> _pausar() async {
    final m = _mision;
    if (m == null) return;
    final motivo = await _pedirTexto('Pausar la visita', 'Motivo', hint: 'Ej. Trámite con el encargado');
    if (motivo == null) return;
    final pausas = List<Map<String, dynamic>>.from(m.pausas);
    pausas.add({
      'inicio': fechaHoraLarga(DateTime.now()),
      'fin': '',
      'motivo': motivo,
    });
    await _guardar({'status': 'pausada', 'pausas': pausas}, exito: 'Visita pausada.');
  }

  Future<void> _reanudar() async {
    final m = _mision;
    if (m == null) return;
    final pausas = List<Map<String, dynamic>>.from(m.pausas);
    if (pausas.isNotEmpty && texto(pausas.last['fin']).isEmpty) {
      pausas[pausas.length - 1] = {
        ...pausas.last,
        'fin': fechaHoraLarga(DateTime.now()),
      };
    }
    final reinicios = listaTexto(m.raw['reinicios'])..add(fechaHoraLarga(DateTime.now()));
    await _guardar({
      'status': 'en_curso',
      'pausas': pausas,
      'reinicios': reinicios,
    }, exito: 'Visita reanudada.');
  }

  Future<void> _sos() async {
    final m = _mision;
    if (m == null) return;
    var causa = 'Riesgo en la tienda';
    final controlador = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, refrescar) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFBE123C)),
              SizedBox(width: 8),
              Text('Alerta SOS', style: TextStyle(fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Se avisará de inmediato a tu coordinador.',
                  style: TextStyle(fontSize: 12.5, color: Tema.tenue),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: causa,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'Riesgo en la tienda', child: Text('Riesgo en la tienda')),
                    DropdownMenuItem(value: 'Accidente', child: Text('Accidente')),
                    DropdownMenuItem(value: 'Inseguridad', child: Text('Inseguridad')),
                    DropdownMenuItem(value: 'Problema con el cliente', child: Text('Problema con el cliente')),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                  ],
                  onChanged: (valor) => refrescar(() => causa = valor ?? 'Otro'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controlador,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: '¿Qué está pasando?'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(contexto).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFBE123C)),
              onPressed: () => Navigator.of(contexto).pop(true),
              child: const Text('Enviar SOS'),
            ),
          ],
        ),
      ),
    );
    if (confirmado != true) return;
    await _guardar({
      'sos': true,
      'sos_causa': causa,
      'sos_comentario': controlador.text.trim(),
      'sos_fecha': fechaHoraLarga(DateTime.now()),
    }, exito: 'Alerta SOS enviada.');
  }

  Future<void> _guardarComentarioGeneral() async {
    await _guardar({'comentarios': _comentario.text.trim()}, exito: 'Comentario guardado.');
  }

  // --- Evidencias -----------------------------------------------------------

  Future<void> _capturarFoto(String actividad, Map<String, dynamic> objetivo) async {
    final m = _mision;
    if (m == null) return;
    final nombreObjetivo = texto(objetivo['nombre']);

    final picker = ImagePicker();
    final foto = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1400,
      imageQuality: 70,
    );
    if (foto == null) return;

    final comentario = await _pedirTexto(
      'Evidencia capturada',
      'Comentario (opcional)',
      hint: 'Detalle de la foto',
      lineas: 2,
    );
    if (comentario == null) return;

    final bytes = await foto.readAsBytes();
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';
    final geo = await Ubicacion.actual();

    setState(() => _guardando = true);
    try {
      final respuesta = await Api.subirEvidencia(m.id, {
        'data_url': dataUrl,
        'tipo': 'foto',
        'nombre': '${nombreObjetivo.isEmpty ? 'evidencia' : nombreObjetivo}.jpg',
        'objetivo': nombreObjetivo,
        'lat': geo?['lat'],
        'lng': geo?['lng'],
      });
      if (respuesta['offline'] == true) {
        _avisar('Sin señal. La evidencia se enviará al recuperar conexión.');
        return;
      }
      final entregable = respuesta['entregable'];
      if (!mounted) return;
      if (entregable is Map) {
        setState(() {
          _entregables = [
            Entregable(Map<String, dynamic>.from(entregable)),
            ..._entregables,
          ];
        });
      }
      if (comentario.isNotEmpty) {
        final mActual = _mision;
        final comentarios = List<Map<String, dynamic>>.from(
          mActual?.comentariosActividades ?? <Map<String, dynamic>>[],
        );
        comentarios.add({
          'actividad': actividad,
          'objetivo': nombreObjetivo,
          'texto': comentario,
          'fecha': fechaHoraLarga(DateTime.now()),
        });
        await _guardar({'comentarios_actividades': comentarios});
      } else {
        _avisar('Evidencia guardada.');
      }
    } on ApiError catch (e) {
      _avisar(e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _comentarObjetivo(String actividad, Map<String, dynamic> objetivo) async {
    final m = _mision;
    if (m == null) return;
    final nombreObjetivo = texto(objetivo['nombre']);
    final escrito = await _pedirTexto(
      'Comentario del objetivo',
      'Comentario',
      hint: '¿Qué encontraste en $nombreObjetivo?',
      requerido: true,
      lineas: 2,
    );
    if (escrito == null || escrito.isEmpty) return;
    final comentarios = List<Map<String, dynamic>>.from(m.comentariosActividades);
    comentarios.add({
      'actividad': actividad,
      'objetivo': nombreObjetivo,
      'texto': escrito,
      'fecha': fechaHoraLarga(DateTime.now()),
    });
    await _guardar({'comentarios_actividades': comentarios}, exito: 'Comentario guardado.');
  }

  Future<void> _firmar() async {
    final m = _mision;
    if (m == null) return;
    final firma = await FirmaDialog.abrir(context);
    if (firma == null) return;
    final geo = await Ubicacion.actual();
    setState(() => _guardando = true);
    try {
      final respuesta = await Api.subirEvidencia(m.id, {
        'data_url': firma,
        'tipo': 'firma',
        'nombre': 'firma-cliente.png',
        'lat': geo?['lat'],
        'lng': geo?['lng'],
      });
      if (respuesta['offline'] == true) {
        _avisar('Sin señal. La firma se enviará al recuperar conexión.');
        return;
      }
      final entregable = respuesta['entregable'];
      if (!mounted) return;
      if (entregable is Map) {
        setState(() {
          _entregables = [
            Entregable(Map<String, dynamic>.from(entregable)),
            ..._entregables,
          ];
        });
      }
      _avisar('Firma guardada.');
      await _cargar();
    } on ApiError catch (e) {
      _avisar(e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _inventario() async {
    final m = _mision;
    if (m == null) return;
    final inicial = TextEditingController(text: '${m.inventarioInicial ?? ''}');
    final finalCantidad = TextEditingController(text: '${m.inventarioFinal ?? ''}');
    final guardar = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Inventario de la visita', style: TextStyle(fontSize: 17)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: inicial,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Inventario inicial'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: finalCantidad,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Inventario final'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (guardar != true) return;
    final valorInicial = int.tryParse(inicial.text.trim()) ?? 0;
    final valorFinal = int.tryParse(finalCantidad.text.trim()) ?? 0;
    await _guardar({
      'inventario_inicial': valorInicial,
      'inventario_final': valorFinal,
      'inventario_vendido': valorInicial - valorFinal > 0 ? valorInicial - valorFinal : 0,
    }, exito: 'Inventario guardado.');
  }

  void _revisarObjetivo(Map<String, dynamic> objetivo) {
    final nombre = texto(objetivo['nombre']);
    final delObjetivo = _entregables.where((e) => e.objetivo == nombre).toList();
    showDialog<void>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(nombre, style: const TextStyle(fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: delObjetivo.isEmpty
              ? const Text(
                  'Todavía no hay evidencias de este objetivo.',
                  style: TextStyle(fontSize: 12.5, color: Tema.tenue),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: delObjetivo
                      .map((e) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: e.tipo == 'foto'
                                ? Image.network(
                                    e.fileUri,
                                    width: 96,
                                    height: 96,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _sinImagen(e),
                                  )
                                : _sinImagen(e),
                          ))
                      .toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _sinImagen(Entregable e) {
    return Container(
      width: 96,
      height: 96,
      color: const Color(0xFFF1F5F9),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            e.tipo == 'firma' ? Icons.draw_outlined : Icons.insert_drive_file_outlined,
            size: 20,
            color: Tema.tenue,
          ),
          const SizedBox(height: 4),
          Text(
            e.tipo,
            style: const TextStyle(fontSize: 9.5, color: Tema.tenue),
          ),
        ],
      ),
    );
  }

  // --- Interfaz -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final m = _mision;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          m == null ? 'Visita' : m.titulo,
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Tema.verde))
          : m == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      _error ?? 'Misión no encontrada.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Tema.tenue),
                    ),
                  ),
                )
              : Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _cargar,
                      color: Tema.verde,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
                        children: [
                          _encabezado(m),
                          if (_sinConexion) ...[
                            const SizedBox(height: 10),
                            _avisoOffline(),
                          ],
                          const SizedBox(height: 12),
                          _acciones(m),
                          const SizedBox(height: 12),
                          _tiempos(m),
                          const SizedBox(height: 12),
                          ObjetivosPanel(
                            mision: m,
                            entregables: _entregables,
                            bloqueado: _guardando,
                            onCambios: (cambios) => _guardar(cambios),
                            onFoto: _capturarFoto,
                            onComentario: _comentarObjetivo,
                            onRevisar: _revisarObjetivo,
                          ),
                          const SizedBox(height: 4),
                          _comentarioGeneral(m),
                          const SizedBox(height: 12),
                          _galeria(),
                        ],
                      ),
                    ),
                    if (_guardando)
                      const Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: LinearProgressIndicator(minHeight: 2, color: Tema.verde),
                      ),
                  ],
                ),
    );
  }

  Widget _encabezado(Mision m) {
    return Tarjeta(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    m.clienteNombre.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.5,
                      letterSpacing: 0.7,
                      fontWeight: FontWeight.w800,
                      color: Tema.tenue,
                    ),
                  ),
                ),
                EstadoPill(status: m.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              m.titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Tema.texto,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (m.tipo.isNotEmpty) _etiqueta(m.tipo),
                if (m.marcaNombre.isNotEmpty) _etiqueta(m.marcaNombre),
                if (m.ordenFolio.isNotEmpty) _etiqueta('Orden ${m.ordenFolio}'),
                if (m.folio.isNotEmpty) _etiqueta('Folio ${m.folio}'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16, color: Tema.borde),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [m.direccion, m.ciudad].where((v) => v.isNotEmpty).join(', '),
                    style: const TextStyle(fontSize: 12.5, color: Tema.tenue),
                  ),
                ),
                if (m.lat != null && m.lng != null)
                  TextButton.icon(
                    onPressed: () => MapaMisionDialog.mostrar(context, m),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Mapa', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Tema.borde),
                const SizedBox(width: 6),
                Text(
                  '${horaCorta(m.horaProgramada)} · ${fechaCorta(m.fechaProgramada)}',
                  style: const TextStyle(fontSize: 12.5, color: Tema.tenue),
                ),
              ],
            ),
            if (m.sos) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'SOS: ${m.sosCausa}${m.sosComentario.isEmpty ? '' : ' · ${m.sosComentario}'}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBE123C),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _etiqueta(String textoEtiqueta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        textoEtiqueta,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Tema.tenue),
      ),
    );
  }

  Widget _avisoOffline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Sin conexión · trabajando con la copia guardada. Lo que registres se enviará al recuperar señal.',
        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
      ),
    );
  }

  Widget _acciones(Mision m) {
    final botones = <Widget>[];
    if (m.status == 'pendiente') {
      botones.add(FilledButton.icon(
        onPressed: _guardando ? null : _iniciar,
        icon: const Icon(Icons.login, size: 18),
        label: Text(m.requiereCheckin ? 'Hacer check-in' : 'Iniciar visita'),
      ));
    } else if (m.status == 'en_curso') {
      botones.add(FilledButton.icon(
        onPressed: _guardando ? null : _checkout,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Hacer check-out'),
      ));
    } else if (m.status == 'pausada') {
      botones.add(FilledButton.icon(
        onPressed: _guardando ? null : _reanudar,
        icon: const Icon(Icons.play_arrow, size: 18),
        label: const Text('Reanudar visita'),
      ));
    } else if (m.status == 'entregada') {
      botones.add(Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Visita entregada. Ya está en revisión del coordinador.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...botones,
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (m.status == 'en_curso')
              OutlinedButton.icon(
                onPressed: _guardando ? null : _pausar,
                icon: const Icon(Icons.pause, size: 17),
                label: const Text('Pausar'),
              ),
            OutlinedButton.icon(
              onPressed: _guardando ? null : _firmar,
              icon: const Icon(Icons.draw_outlined, size: 17),
              label: Text(m.firmaUri.isEmpty ? 'Firma' : 'Nueva firma'),
            ),
            if (m.tipo == 'inventario')
              OutlinedButton.icon(
                onPressed: _guardando ? null : _inventario,
                icon: const Icon(Icons.inventory_2_outlined, size: 17),
                label: const Text('Inventario'),
              ),
            OutlinedButton.icon(
              onPressed: _guardando ? null : _sos,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFBE123C),
                side: const BorderSide(color: Color(0xFFFECDD3)),
              ),
              icon: const Icon(Icons.warning_amber_rounded, size: 18),
              label: const Text('SOS'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tiempos(Mision m) {
    final filas = <Widget>[
      _dato('Check-in', m.checkinHora.isEmpty ? 'Sin registrar' : horaCorta(m.checkinHora)),
      _dato('Check-out', m.checkoutHora.isEmpty ? 'Sin registrar' : horaCorta(m.checkoutHora)),
      _dato('Avance', '${m.avance}%'),
      if (m.pausas.isNotEmpty) _dato('Pausas', '${m.pausas.length}'),
      if (m.minutos != null) _dato('Minutos en sitio', '${m.minutos}'),
    ];
    return Tarjeta(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (m.avance / 100).clamp(0, 1).toDouble(),
                minHeight: 7,
                backgroundColor: const Color(0xFFF1F5F9),
                color: Tema.verde,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(spacing: 18, runSpacing: 10, children: filas),
          ],
        ),
      ),
    );
  }

  Widget _dato(String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          etiqueta.toUpperCase(),
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: Tema.tenue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Tema.texto),
        ),
      ],
    );
  }

  Widget _comentarioGeneral(Mision m) {
    return Tarjeta(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'COMENTARIO GENERAL DE LA VISITA',
              style: TextStyle(
                fontSize: 10.5,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
                color: Tema.tenue,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comentario,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Observaciones de la tienda, incidencias, etc.'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _guardando ? null : _guardarComentarioGeneral,
                child: const Text('Guardar comentario'),
              ),
            ),
            if (m.comentariosActividades.isNotEmpty) ...[
              const Divider(height: 20),
              const Text(
                'COMENTARIOS POR OBJETIVO',
                style: TextStyle(
                  fontSize: 10.5,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w800,
                  color: Tema.tenue,
                ),
              ),
              const SizedBox(height: 6),
              ...m.comentariosActividades.map(
                (c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        texto(c['objetivo']).isEmpty ? texto(c['actividad']) : texto(c['objetivo']),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Tema.texto,
                        ),
                      ),
                      Text(
                        texto(c['texto']),
                        style: const TextStyle(fontSize: 12, color: Tema.tenue, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _galeria() {
    final fotos = _entregables.where((e) => e.tipo == 'foto').toList();
    return Tarjeta(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EVIDENCIAS (${_entregables.length})',
              style: const TextStyle(
                fontSize: 10.5,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
                color: Tema.tenue,
              ),
            ),
            const SizedBox(height: 10),
            if (_entregables.isEmpty)
              const Text(
                'Aún no hay evidencias capturadas en esta visita.',
                style: TextStyle(fontSize: 12, color: Tema.tenue),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _entregables.map((e) {
                  return GestureDetector(
                    onTap: () => _verEvidencia(e),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: e.tipo == 'foto'
                          ? Image.network(
                              e.fileUri,
                              width: 82,
                              height: 82,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _sinImagen(e),
                            )
                          : _sinImagen(e),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _verEvidencia(Entregable e) {
    showDialog<void>(
      context: context,
      builder: (contexto) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.objetivo.isEmpty ? e.nombre : e.objetivo,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              if (e.tipo == 'foto')
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    e.fileUri,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _sinImagen(e),
                  ),
                )
              else
                _sinImagen(e),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(contexto).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}