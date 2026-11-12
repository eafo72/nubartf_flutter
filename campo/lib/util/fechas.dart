const List<String> _dias = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

const List<String> _meses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String dos(int n) => n.toString().padLeft(2, '0');

/// Fecha de hoy en el formato que guarda el servidor (America/Mexico_City).
String hoyIso() {
  final n = DateTime.now();
  return '${n.year}-${dos(n.month)}-${dos(n.day)}';
}

String fechaIso(DateTime d) => '${d.year}-${dos(d.month)}-${dos(d.day)}';

String horaLarga(DateTime d) => '${dos(d.hour)}:${dos(d.minute)}:${dos(d.second)}';

String fechaHoraLarga(DateTime d) => '${fechaIso(d)} ${horaLarga(d)}';

String fechaLarga(DateTime d) => '${_dias[d.weekday - 1]} ${d.day} de ${_meses[d.month - 1]}';

String mesTitulo(DateTime d) {
  final nombre = _meses[d.month - 1];
  return '${nombre[0].toUpperCase()}${nombre.substring(1)} ${d.year}';
}

String inicialDia(int weekday) => ['L', 'M', 'M', 'J', 'V', 'S', 'D'][weekday - 1];

/// '2026-11-05' -> '5 nov'
String fechaCorta(String? iso) {
  final d = DateTime.tryParse(iso ?? '');
  if (d == null) return iso ?? '';
  return '${d.day} ${_meses[d.month - 1].substring(0, 3)}';
}

/// '09:05:00' -> '09:05'
String horaCorta(String? hora) {
  final texto = hora ?? '';
  return texto.length >= 5 ? texto.substring(0, 5) : texto;
}

int? minutosDesde(String? horaInicio) {
  final partes = (horaInicio ?? '').split(':');
  if (partes.length < 2) return null;
  final h = int.tryParse(partes[0]);
  final m = int.tryParse(partes[1]);
  if (h == null || m == null) return null;
  final ahora = DateTime.now();
  final minutos = (ahora.hour * 60 + ahora.minute) - (h * 60 + m);
  return minutos > 0 ? minutos : null;
}