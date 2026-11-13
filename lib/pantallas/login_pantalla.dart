import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../tema.dart';

/// Pantalla 1: inicio de sesión con correo y contraseña (Firebase Authentication).
class LoginPantalla extends StatefulWidget {
  const LoginPantalla({super.key});

  @override
  State<LoginPantalla> createState() => _LoginPantallaState();
}

class _LoginPantallaState extends State<LoginPantalla> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _ocultar = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  String _mensajeDeError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Correo o contraseña incorrectos.';
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos.';
      case 'network-request-failed':
        return 'No hay conexión a internet.';
      default:
        return 'No se pudo iniciar sesión (${e.code}).';
    }
  }

  Future<void> _entrar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _correo.text.trim(),
        password: _contrasena.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _mensajeDeError(e));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Form(
              key: _formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colores.primario,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Revisión de publicaciones',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Entra con tu cuenta de Metricser para ver las piezas pendientes de tu equipo.',
                    style: TextStyle(color: Colores.textoSecundario, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _correo,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: decoracionCampo('Correo de la agencia'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Escribe tu correo' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _contrasena,
                    obscureText: _ocultar,
                    decoration: decoracionCampo(
                      'Contraseña',
                      sufijo: TextButton(
                        onPressed: () => setState(() => _ocultar = !_ocultar),
                        child: Text(_ocultar ? 'Mostrar' : 'Ocultar'),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Escribe tu contraseña' : null,
                    onFieldSubmitted: (_) => _entrar(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _cargando ? null : _entrar,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Iniciar sesión', style: TextStyle(fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
