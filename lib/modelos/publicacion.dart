import 'package:cloud_firestore/cloud_firestore.dart';

/// Un punto de la checklist de revisión.
class PuntoRevision {
  const PuntoRevision(this.clave, this.nombre);

  final String clave;
  final String nombre;
}

/// Los cinco puntos que se revisan antes de publicar.
/// Las claves deben coincidir con las reglas de seguridad de Firestore.
const List<PuntoRevision> puntosRevision = [
  PuntoRevision('ortografia', 'Ortografía revisada'),
  PuntoRevision('logo', 'Logo y marca correctos'),
  PuntoRevision('horario', 'Horario confirmado'),
  PuntoRevision('aprobacion', 'Aprobación del cliente'),
  PuntoRevision('formato', 'Formato de la plataforma'),
];

/// Redes permitidas. Deben coincidir con las reglas de Firestore.
const List<String> redesSociales = ['Instagram', 'Facebook', 'TikTok', 'X'];

/// Estado de un punto de la checklist: si está hecho y quién lo marcó.
class EstadoPunto {
  const EstadoPunto({required this.hecho, this.por});

  final bool hecho;
  final String? por;

  factory EstadoPunto.desdeMapa(Object? valor) {
    if (valor is Map) {
      return EstadoPunto(
        hecho: valor['hecho'] == true,
        por: valor['por'] as String?,
      );
    }
    return const EstadoPunto(hecho: false);
  }

  Map<String, dynamic> aMapa() => {'hecho': hecho, 'por': por};
}

/// Una publicación que se revisa antes de salir en redes sociales.
class Publicacion {
  const Publicacion({
    required this.id,
    required this.cliente,
    required this.titulo,
    required this.redSocial,
    required this.texto,
    required this.fechaPublicacion,
    required this.estado,
    required this.checklist,
    required this.creadoPor,
    required this.creadoPorNombre,
  });

  final String id;
  final String cliente;
  final String titulo;
  final String redSocial;
  final String texto;
  final DateTime fechaPublicacion;
  final String estado;
  final Map<String, EstadoPunto> checklist;
  final String creadoPor;
  final String creadoPorNombre;

  bool get estaLista => estado == 'listo';

  int get puntosHechos => checklist.values.where((p) => p.hecho).length;

  factory Publicacion.desdeDocumento(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    final mapa = (d['checklist'] as Map?) ?? {};
    return Publicacion(
      id: doc.id,
      cliente: (d['cliente'] as String?) ?? '',
      titulo: (d['titulo'] as String?) ?? '',
      redSocial: (d['redSocial'] as String?) ?? 'Instagram',
      texto: (d['texto'] as String?) ?? '',
      fechaPublicacion:
          (d['fechaPublicacion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estado: (d['estado'] as String?) ?? 'pendiente',
      checklist: {
        for (final p in puntosRevision) p.clave: EstadoPunto.desdeMapa(mapa[p.clave]),
      },
      creadoPor: (d['creadoPor'] as String?) ?? '',
      creadoPorNombre: (d['creadoPorNombre'] as String?) ?? '',
    );
  }

  /// Checklist con los cinco puntos sin marcar, para publicaciones nuevas.
  static Map<String, dynamic> checklistVacio() => {
        for (final p in puntosRevision) p.clave: const EstadoPunto(hecho: false).aMapa(),
      };

  /// "listo" solo si los cinco puntos están marcados.
  static String calcularEstado(Map<String, EstadoPunto> checklist) {
    final todos = puntosRevision.every((p) => checklist[p.clave]?.hecho == true);
    return todos ? 'listo' : 'pendiente';
  }

  // Validaciones del formulario. Repiten las reglas de Firestore para avisar
  // al usuario antes de enviar los datos.
  static String? validarCliente(String? valor) {
    final t = valor?.trim() ?? '';
    if (t.isEmpty) return 'Escribe el nombre del cliente';
    if (t.length > 100) return 'Máximo 100 caracteres';
    return null;
  }

  static String? validarTitulo(String? valor) {
    final t = valor?.trim() ?? '';
    if (t.isEmpty) return 'Escribe el título de la pieza';
    if (t.length > 150) return 'Máximo 150 caracteres';
    return null;
  }

  static String? validarTexto(String? valor) {
    if ((valor ?? '').length > 2200) return 'Máximo 2,200 caracteres';
    return null;
  }
}
