import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models.dart';

class Pendiente {
  final int id;
  final String tipo;
  final String misionId;
  final Map<String, dynamic> payload;

  Pendiente({
    required this.id,
    required this.tipo,
    required this.misionId,
    required this.payload,
  });
}

/// Base local del teléfono: guarda la última lista de misiones para consultarla
/// sin señal y la cola de registros que todavía no llegan al servidor.
class LocalDb {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    final ruta = p.join(await getDatabasesPath(), 'rtf_campo.db');
    _db = await openDatabase(
      ruta,
      version: 1,
      onCreate: (base, version) async {
        await base.execute(
          'CREATE TABLE cola (id INTEGER PRIMARY KEY AUTOINCREMENT, tipo TEXT NOT NULL, '
          'mision_id TEXT, payload TEXT NOT NULL, creado TEXT NOT NULL)',
        );
        await base.execute(
          'CREATE TABLE misiones (id TEXT PRIMARY KEY, datos TEXT NOT NULL, actualizado TEXT NOT NULL)',
        );
      },
    );
    return _db!;
  }

  static Future<void> guardarMisiones(List<Mision> misiones) async {
    final base = await db;
    final lote = base.batch();
    for (final m in misiones) {
      lote.insert(
        'misiones',
        {
          'id': m.id,
          'datos': jsonEncode(m.raw),
          'actualizado': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await lote.commit();
  }

  static Future<void> guardarMision(Mision mision) async {
    final base = await db;
    await base.insert(
      'misiones',
      {
        'id': mision.id,
        'datos': jsonEncode(mision.raw),
        'actualizado': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Mision>> misionesGuardadas() async {
    final base = await db;
    final filas = await base.query('misiones', orderBy: 'actualizado DESC');
    final lista = <Mision>[];
    for (final f in filas) {
      final guardada = _leerMision(f['datos']);
      if (guardada != null) lista.add(guardada);
    }
    return lista;
  }

  static Future<Mision?> misionGuardada(String id) async {
    final base = await db;
    final filas = await base.query('misiones', where: 'id = ?', whereArgs: [id], limit: 1);
    if (filas.isEmpty) return null;
    return _leerMision(filas.first['datos']);
  }

  static Mision? _leerMision(dynamic contenido) {
    try {
      final decodificado = jsonDecode('$contenido');
      return Mision.fromJson(decodificado);
    } catch (_) {
      return null;
    }
  }

  static Future<void> encolar(
    String tipo,
    String misionId,
    Map<String, dynamic> payload,
  ) async {
    final base = await db;
    await base.insert('cola', {
      'tipo': tipo,
      'mision_id': misionId,
      'payload': jsonEncode(payload),
      'creado': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Pendiente>> cola() async {
    final base = await db;
    final filas = await base.query('cola', orderBy: 'id ASC');
    final lista = <Pendiente>[];
    for (final f in filas) {
      try {
        final payload = jsonDecode('${f['payload']}');
        lista.add(Pendiente(
          id: f['id'] as int,
          tipo: '${f['tipo']}',
          misionId: '${f['mision_id'] ?? ''}',
          payload: payload is Map ? Map<String, dynamic>.from(payload) : <String, dynamic>{},
        ));
      } catch (_) {
        // Un renglón ilegible no debe detener la cola completa.
      }
    }
    return lista;
  }

  static Future<void> borrarPendiente(int id) async {
    final base = await db;
    await base.delete('cola', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> contarPendientes() async {
    final base = await db;
    final filas = await base.rawQuery('SELECT COUNT(*) AS n FROM cola');
    final valor = filas.isEmpty ? null : filas.first['n'];
    return valor is int ? valor : 0;
  }
}