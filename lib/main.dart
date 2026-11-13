import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'pantallas/lista_pantalla.dart';
import 'pantallas/login_pantalla.dart';
import 'servicios/avisos_servicio.dart';
import 'tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // App Check es obligatorio para usar Gemini con Firebase AI Logic.
  // En desarrollo se usa el proveedor de depuración; su token se registra
  // en la consola de Firebase (Seguridad > App Check > Administrar tokens).
  await FirebaseAppCheck.instance.activate(
    providerAndroid: const AndroidDebugProvider(),
  );

  await initializeDateFormatting('es_MX');
  await AvisosServicio.instancia.inicializar();
  runApp(const RevisionApp());
}

class RevisionApp extends StatelessWidget {
  const RevisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Revisión de publicaciones',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const PuertaSesion(),
    );
  }
}

/// Muestra el inicio de sesión o la lista según haya sesión iniciada,
/// y activa los avisos solo para el usuario con sesión.
class PuertaSesion extends StatefulWidget {
  const PuertaSesion({super.key});

  @override
  State<PuertaSesion> createState() => _PuertaSesionState();
}

class _PuertaSesionState extends State<PuertaSesion> {
  late final StreamSubscription<User?> _suscripcion;
  User? _usuario;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _suscripcion = FirebaseAuth.instance.authStateChanges().listen((usuario) {
      if (usuario != null) {
        AvisosServicio.instancia.escuchar(usuario.uid);
      } else {
        AvisosServicio.instancia.detener();
      }
      setState(() {
        _usuario = usuario;
        _cargando = false;
      });
    });
  }

  @override
  void dispose() {
    _suscripcion.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _usuario == null ? const LoginPantalla() : const ListaPantalla();
  }
}
