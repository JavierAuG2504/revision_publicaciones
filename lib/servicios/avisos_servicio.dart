import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Aviso dentro de la app: cuando una publicación creada por el usuario
/// cambia de "pendiente" a "listo", muestra una notificación local.
/// Funciona mientras la app está abierta o en segundo plano reciente.
class AvisosServicio {
  AvisosServicio._();

  static final AvisosServicio instancia = AvisosServicio._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _suscripcion;
  final Map<String, String> _estados = {};
  bool _primeraCarga = true;
  bool _iniciado = false;

  Future<void> inicializar() async {
    if (_iniciado) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(settings: const InitializationSettings(android: android));
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _iniciado = true;
  }

  void escuchar(String uid) {
    detener();
    _primeraCarga = true;
    _suscripcion = FirebaseFirestore.instance
        .collection('publicaciones')
        .where('creadoPor', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      for (final doc in snapshot.docs) {
        final datos = doc.data();
        final estado = (datos['estado'] as String?) ?? 'pendiente';
        final anterior = _estados[doc.id];
        if (!_primeraCarga && anterior == 'pendiente' && estado == 'listo') {
          _mostrar(doc.id.hashCode, (datos['titulo'] as String?) ?? 'Publicación');
        }
        _estados[doc.id] = estado;
      }
      _primeraCarga = false;
    });
  }

  void detener() {
    _suscripcion?.cancel();
    _suscripcion = null;
    _estados.clear();
  }

  Future<void> _mostrar(int id, String titulo) {
    return _plugin.show(
      id: id,
      title: 'Lista para publicar',
      body: '"$titulo" ya pasó los 5 puntos de revisión.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'revisiones',
          'Revisiones',
          channelDescription: 'Avisos cuando una publicación queda lista',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}
