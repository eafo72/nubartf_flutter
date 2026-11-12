import 'package:flutter/material.dart';

import '../models.dart';
import '../tema.dart';
import 'tarjeta.dart';

/// Objetivos de la visita agrupados por actividad. Cada objetivo se marca como
/// cumplido y desde ahí se captura su evidencia o su comentario.
class ObjetivosPanel extends StatelessWidget {
  final Mision mision;
  final List<Entregable> entregables;
  final bool bloqueado;
  final ValueChanged<Map<String, dynamic>> onCambios;
  final void Function(String actividad, Map<String, dynamic> objetivo) onFoto;
  final void Function(String actividad, Map<String, dynamic> objetivo) onComentario;
  final void Function(Map<String, dynamic> objetivo) onRevisar;

  const ObjetivosPanel({
    super.key,
    required this.mision,
    required this.entregables,
    required this.onCambios,
    required this.onFoto,
    required this.onComentario,
    required this.onRevisar,
    this.bloqueado = false,
  });

  int get _total {
    var suma = 0;
    mision.objetivosPorActividad.forEach((_, lista) => suma += lista.length);
    return suma;
  }

  void _alternar(Map<String, dynamic> objetivo, bool cumplido) {
    final nombre = texto(objetivo['nombre']);
    final nuevos = List<String>.from(mision.objetivosOk);
    if (cumplido) {
      if (!nuevos.contains(nombre)) nuevos.add(nombre);
    } else {
      nuevos.remove(nombre);
    }
    final total = _total == 0 ? 1 : _total;
    final avance = ((nuevos.length / total) * 100).round().clamp(0, 100);
    onCambios({'objetivos_ok': nuevos, 'avance': avance});
  }

  @override
  Widget build(BuildContext context) {
    final grupos = mision.objetivosPorActividad;
    if (_total == 0) {
      return Tarjeta(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: const [
              Icon(Icons.checklist_rtl, size: 30, color: Tema.borde),
              SizedBox(height: 8),
              Text(
                'Esta visita no tiene objetivos configurados.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Tema.tenue),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'OBJETIVOS POR ACTIVIDAD',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: Tema.tenue,
            ),
          ),
        ),
        ...grupos.entries.map((grupo) {
          final lista = grupo.value;
          final cumplidos = lista
              .where((o) => mision.objetivoCumplido(texto(o['nombre'])))
              .length;
          final completo = cumplidos == lista.length && lista.isNotEmpty;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Tarjeta(
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  leading: Icon(
                    completo ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: completo ? Tema.verde : Tema.borde,
                    size: 20,
                  ),
                  title: Text(
                    grupo.key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Tema.texto,
                    ),
                  ),
                  subtitle: Text(
                    '$cumplidos de ${lista.length} objetivos',
                    style: const TextStyle(fontSize: 11.5, color: Tema.tenue),
                  ),
                  children: lista.map((objetivo) {
                    final nombre = texto(objetivo['nombre']);
                    final cumplido = mision.objetivoCumplido(nombre);
                    final evidencias =
                        entregables.where((e) => e.objetivo == nombre).length;
                    final comentarios = mision.comentariosActividades
                        .where((c) => texto(c['objetivo']) == nombre)
                        .length;
                    return InkWell(
                      onTap: () => onRevisar(objetivo),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: cumplido,
                              activeColor: Tema.verde,
                              onChanged: bloqueado
                                  ? null
                                  : (valor) => _alternar(objetivo, valor ?? false),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nombre,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: cumplido ? Tema.texto : Tema.tenue,
                                      decoration:
                                          cumplido ? null : TextDecoration.none,
                                    ),
                                  ),
                                  if (evidencias > 0 || comentarios > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        [
                                          if (evidencias > 0)
                                            '$evidencias evidencia${evidencias == 1 ? '' : 's'}',
                                          if (comentarios > 0) '$comentarios comentario${comentarios == 1 ? '' : 's'}',
                                        ].join(' · '),
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: Tema.verdeOscuro,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: bloqueado ? null : () => onFoto(grupo.key, objetivo),
                              icon: const Icon(Icons.photo_camera_outlined, size: 19),
                              color: Tema.navy,
                              tooltip: 'Capturar evidencia',
                            ),
                            IconButton(
                              onPressed: bloqueado
                                  ? null
                                  : () => onComentario(grupo.key, objetivo),
                              icon: const Icon(Icons.mode_comment_outlined, size: 18),
                              color: Tema.tenue,
                              tooltip: 'Comentar objetivo',
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}