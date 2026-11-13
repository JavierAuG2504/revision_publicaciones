import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../modelos/publicacion.dart';

/// Operaciones CRUD sobre la colección "publicaciones" de Cloud Firestore.
class PublicacionesServicio {
  PublicacionesServicio._();

  static final PublicacionesServicio instancia = PublicacionesServicio._();

  final CollectionReference<Map<String, dynamic>> _coleccion =
      FirebaseFirestore.instance.collection('publicaciones');

  User get _usuario => FirebaseAuth.instance.currentUser!;

  static String nombreDe(User usuario) {
    final nombre = usuario.displayName;
    if (nombre != null && nombre.isNotEmpty) return nombre;
    return (usuario.email ?? 'usuario').split('@').first;
  }

  // CREATE
  Future<void> crear({
    required String cliente,
    required String titulo,
    required String redSocial,
    required String texto,
    required DateTime fechaPublicacion,
  }) {
    return _coleccion.add({
      'cliente': cliente.trim(),
      'titulo': titulo.trim(),
      'redSocial': redSocial,
      'texto': texto.trim(),
      'fechaPublicacion': Timestamp.fromDate(fechaPublicacion),
      'estado': 'pendiente',
      'checklist': Publicacion.checklistVacio(),
      'creadoPor': _usuario.uid,
      'creadoPorNombre': nombreDe(_usuario),
      'creadoEn': FieldValue.serverTimestamp(),
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
  }

  // READ: todas las publicaciones, ordenadas por fecha de publicación.
  Stream<List<Publicacion>> todas() {
    return _coleccion
        .orderBy('fechaPublicacion')
        .snapshots()
        .map((s) => s.docs.map(Publicacion.desdeDocumento).toList());
  }

  // READ: una publicación, en tiempo real.
  Stream<Publicacion?> una(String id) {
    return _coleccion
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? Publicacion.desdeDocumento(d) : null);
  }

  // UPDATE: datos generales (desde el formulario de edición).
  Future<void> actualizarDatos({
    required String id,
    required String cliente,
    required String titulo,
    required String redSocial,
    required String texto,
    required DateTime fechaPublicacion,
  }) {
    return _coleccion.doc(id).update({
      'cliente': cliente.trim(),
      'titulo': titulo.trim(),
      'redSocial': redSocial,
      'texto': texto.trim(),
      'fechaPublicacion': Timestamp.fromDate(fechaPublicacion),
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE: marcar o desmarcar un punto de la checklist y recalcular el estado.
  Future<void> marcarPunto(Publicacion publicacion, String clave, bool hecho) {
    final nuevo = Map<String, EstadoPunto>.from(publicacion.checklist);
    nuevo[clave] = EstadoPunto(hecho: hecho, por: hecho ? nombreDe(_usuario) : null);
    return _coleccion.doc(publicacion.id).update({
      'checklist.$clave': nuevo[clave]!.aMapa(),
      'estado': Publicacion.calcularEstado(nuevo),
      'actualizadoEn': FieldValue.serverTimestamp(),
    });
  }

  // DELETE: las reglas de Firestore solo lo permiten a quien la creó.
  Future<void> eliminar(String id) => _coleccion.doc(id).delete();

  bool esCreador(Publicacion publicacion) => publicacion.creadoPor == _usuario.uid;
}
