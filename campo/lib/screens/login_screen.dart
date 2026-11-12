import 'package:flutter/material.dart';

import '../services/api.dart';
import '../tema.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuario = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  bool _verClave = false;
  bool _entrando = false;
  String? _error;

  @override
  void dispose() {
    _usuario.dispose();
    _clave.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final usuario = _usuario.text.trim();
    final clave = _clave.text;
    if (usuario.isEmpty || clave.isEmpty) {
      setState(() => _error = 'Escribe tu usuario y tu contraseña.');
      return;
    }
    setState(() {
      _entrando = true;
      _error = null;
    });
    try {
      await Api.login(usuario, clave);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (ruta) => false);
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.sinConexion
            ? 'Sin conexión. Revisa tu red e intenta de nuevo.'
            : e.mensaje;
      });
    } finally {
      if (mounted) setState(() => _entrando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tema.navy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'rtf',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Tema.navy,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Tema.verde,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text(
                        '2.0',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Tema.navy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'App de campo',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Entra con el usuario y la clave que te dio tu administrador.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFB8C4D6), height: 1.4),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'USUARIO',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Tema.tenue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _usuario,
                        autocorrect: false,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(hintText: 'tu.usuario'),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'CONTRASEÑA',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Tema.tenue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _clave,
                        obscureText: !_verClave,
                        onSubmitted: (_) => _entrando ? null : _entrar(),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _verClave = !_verClave),
                            icon: Icon(
                              _verClave ? Icons.visibility_off : Icons.visibility,
                              size: 20,
                              color: Tema.tenue,
                            ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFBE123C),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _entrando ? null : _entrar,
                        child: Text(_entrando ? 'Entrando…' : 'Entrar'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Si olvidaste tu clave, pídele a tu coordinador que la restablezca desde el panel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF8FA0B8), height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}