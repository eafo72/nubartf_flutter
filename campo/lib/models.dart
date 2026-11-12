double? numero(dynamic v) {
  if (v is num) return v.toDouble();
  if (v == null) return null;
  return double.tryParse('$v');
}

int? entero(dynamic v) => numero(v)?.round();

String texto(dynamic v) => v == null ? '' : '$v';

List<String> listaTexto(dynamic v) =>
    v is List ? v.map((e) => '$e').toList() : <String>[];

List<Map<String, dynamic>> listaMapas(dynamic v) => v is List
    ? v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList()
    : <Map<String, dynamic>>[];

class Colaborador {
  final String id;
  final String nombre;
  final String apellidos;
  final String puesto;
  final String email;
  final String empresaId;
  final String empresaNombre;
  final String fotoUrl;

  const Colaborador({
    this.id = '',
    this.nombre = '',
    this.apellidos = '',
    this.puesto = '',
    this.email = '',
    this.empresaId = '',
    this.empresaNombre = '',
    this.fotoUrl = '',
  });

  static Colaborador fromJson(dynamic v) {
    final m = v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
    return Colaborador(
      id: texto(m['id']),
      nombre: texto(m['nombre']),
      apellidos: texto(m['apellidos']),
      puesto: texto(m['puesto']),
      email: texto(m['email']),
      empresaId: texto(m['empresa_id']),
      empresaNombre: texto(m['empresa_nombre']),
      fotoUrl: texto(m['foto_url']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'apellidos': apellidos,
        'puesto': puesto,
        'email': email,
        'empresa_id': empresaId,
        'empresa_nombre': empresaNombre,
        'foto_url': fotoUrl,
      };

  String get nombreCompleto => '$nombre $apellidos'.trim();
}

/// La misión se guarda tal como llega del servidor; los campos se leen con
/// getters para no perder datos que la app móvil todavía no usa.
class Mision {
  final Map<String, dynamic> raw;

  Mision(this.raw);

  static Mision? fromJson(dynamic v) =>
      v is Map ? Mision(Map<String, dynamic>.from(v)) : null;

  String get id => texto(raw['id']);
  String get folio => texto(raw['folio']);
  String get titulo => texto(raw['titulo']);
  String get tipo => texto(raw['tipo']);
  String get actividadNombre => texto(raw['actividad_nombre']);
  String get clienteNombre => texto(raw['cliente_nombre']);
  String get marcaNombre => texto(raw['marca_nombre']);
  String get ordenFolio => texto(raw['orden_folio']);
  String get direccion => texto(raw['direccion']);
  String get ciudad => texto(raw['ciudad']);
  double? get lat => numero(raw['lat']);
  double? get lng => numero(raw['lng']);
  String get fechaProgramada => texto(raw['fecha_programada']);
  String get horaProgramada => texto(raw['hora_programada']);
  String get status => texto(raw['status']).isEmpty ? 'pendiente' : texto(raw['status']);
  bool get requiereCheckin => raw['requiere_checkin'] != false;
  bool get requiereCheckout => raw['requiere_checkout'] != false;

  String get checkinHora => texto(raw['checkin_hora']);
  String get checkoutHora => texto(raw['checkout_hora']);
  String get resultado => texto(raw['resultado']);
  bool get sos => raw['sos'] == true;
  String get sosCausa => texto(raw['sos_causa']);
  String get sosComentario => texto(raw['sos_comentario']);
  String get comentario => texto(raw['comentarios']);
  String get firmaUri => texto(raw['firma_uri']);
  int get avance => entero(raw['avance']) ?? 0;
  int? get minutos => entero(raw['minutos']);

  int? get inventarioInicial => entero(raw['inventario_inicial']);
  int? get inventarioFinal => entero(raw['inventario_final']);

  List<String> get objetivos => listaTexto(raw['objetivos']);
  List<String> get objetivosOk => listaTexto(raw['objetivos_ok']);
  List<Map<String, dynamic>> get objetivosDetalle => listaMapas(raw['objetivos_detalle']);
  List<Map<String, dynamic>> get pausas => listaMapas(raw['pausas']);
  List<Map<String, dynamic>> get comentariosActividades => listaMapas(raw['comentarios_actividades']);

  bool objetivoCumplido(String objetivo) => objetivosOk.contains(objetivo);

  /// Objetivos agrupados por actividad, respetando la actividad de cada uno.
  Map<String, List<Map<String, dynamic>>> get objetivosPorActividad {
    final grupos = <String, List<Map<String, dynamic>>>{};
    if (objetivosDetalle.isNotEmpty) {
      for (final o in objetivosDetalle) {
        final actividad = texto(o['actividad']).isEmpty
            ? (actividadNombre.isEmpty ? 'Objetivos' : actividadNombre)
            : texto(o['actividad']);
        grupos.putIfAbsent(actividad, () => []).add(o);
      }
      return grupos;
    }
    final base = actividadNombre.isEmpty ? 'Objetivos' : actividadNombre;
    grupos[base] = objetivos
        .map((nombre) => <String, dynamic>{'nombre': nombre, 'tipo': 'texto'})
        .toList();
    return grupos;
  }

  Map<String, dynamic> fusionar(Map<String, dynamic> cambios) =>
      Mision({...raw, ...cambios}).raw;
}

class Entregable {
  final Map<String, dynamic> raw;
  Entregable(this.raw);

  static Entregable? fromJson(dynamic v) =>
      v is Map ? Entregable(Map<String, dynamic>.from(v)) : null;

  String get id => texto(raw['id']);
  String get tipo => texto(raw['tipo']);
  String get nombre => texto(raw['nombre']);
  String get objetivo => texto(raw['objetivo']);
  String get fileUri => texto(raw['file_uri']);
  String get categoria => texto(raw['categoria']);
  String get comentario => texto(raw['comentario']);
}

class Asistencia {
  final Map<String, dynamic> raw;
  Asistencia(this.raw);

  static Asistencia? fromJson(dynamic v) =>
      v is Map ? Asistencia(Map<String, dynamic>.from(v)) : null;

  String get id => texto(raw['id']);
  String get fecha => texto(raw['fecha']);
  String get tipo => texto(raw['tipo']);
  String get hora => texto(raw['hora']);
  String get direccion => texto(raw['direccion']);
  String get notas => texto(raw['notas']);
}

class Viatico {
  final Map<String, dynamic> raw;
  Viatico(this.raw);

  static Viatico? fromJson(dynamic v) =>
      v is Map ? Viatico(Map<String, dynamic>.from(v)) : null;

  String get id => texto(raw['id']);
  String get fecha => texto(raw['fecha']);
  String get concepto => texto(raw['concepto']);
  double get monto => numero(raw['monto']) ?? 0;
  String get status => texto(raw['status']).isEmpty ? 'pendiente' : texto(raw['status']);
  String get misionTitulo => texto(raw['mision_titulo']);
  String get notas => texto(raw['notas']);
  String get comprobanteUri => texto(raw['comprobante_uri']);
}