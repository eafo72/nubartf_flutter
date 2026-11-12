import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../services/api.dart';
import '../services/local_db.dart';
import '../services/sync_service.dart';
import '../tema.dart';
import 'asistencia_screen.dart';
import 'misiones_screen.dart';
import 'viaticos_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _indice = 0;
  int _pendientes = 0;
  StreamSubscription<List<ConnectivityResult>>? _conexion;

  @override
  void initState() {
    super.initState();
    _refrescarCola();
    _escucharConexion();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final enviados = await SyncService.enviarPendientes();
      await _refrescarCola();
      if (enviados > 0 && mounted) {
        _avisar('$enviados registros pendientes se enviaron');
      }
    });
  }

  @override
  void dispose() {
    _conexion?.cancel();
    super.dispose();
  }

  Future<void> _refrescarCola() async {
    final total = await LocalDb.contarPendientes();
    if (mounted) setState(() => _pendientes = total);
  }

  void _escucharConexion() {
    _conexion = Connectivity().onConnectivityChanged.listen((resultado) async {
      final sinRed = resultado.isEmpty || resultado.contains(ConnectivityResult.none);
      if (sinRed) return;
      final enviados = await SyncService.enviarPendientes();
      await _refrescarCola();
      if (enviados > 0 && mounted) {
        _avisar('$enviados registros sincronizados');
      }
    });
  }

  void _avisar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _salir() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: const Text('Cerrar sesión', style: TextStyle(fontSize: 17)),
        content: const Text('¿Quieres salir de la app de campo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    await Api.cerrarSesion();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (ruta) => false);
  }

  @override
  Widget build(BuildContext context) {
    final quien = Api.colaborador;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'RTF 2.0',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              quien?.empresaNombre.isNotEmpty == true
                  ? quien!.empresaNombre
                  : 'App de campo',
              style: const TextStyle(fontSize: 11, color: Tema.tenue),
            ),
          ],
        ),
        actions: [
          if (_pendientes > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                label: Text('$_pendientes en cola'),
                labelStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                backgroundColor: const Color(0xFFFEF3C7),
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            ),
          IconButton(
            onPressed: _salir,
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, size: 20),
          ),
        ],
      ),
      body: IndexedStack(
        index: _indice,
        children: [
          MisionesScreen(onColaCambio: _refrescarCola),
          const AsistenciaScreen(),
          const ViaticosScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (valor) => setState(() => _indice = valor),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFEEF7E6),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment, color: Tema.verdeOscuro),
            label: 'Misiones',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time, color: Tema.verdeOscuro),
            label: 'Asistencia',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Tema.verdeOscuro),
            label: 'Viáticos',
          ),
        ],
      ),
    );
  }
}