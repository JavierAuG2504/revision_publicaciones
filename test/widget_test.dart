import 'package:flutter_test/flutter_test.dart';
import 'package:revision_publicaciones/modelos/publicacion.dart';

void main() {
  group('Validaciones del formulario', () {
    test('cliente vacío no es válido', () {
      expect(Publicacion.validarCliente(''), isNotNull);
      expect(Publicacion.validarCliente('   '), isNotNull);
    });

    test('cliente de más de 100 caracteres no es válido', () {
      expect(Publicacion.validarCliente('a' * 101), isNotNull);
    });

    test('cliente normal es válido', () {
      expect(Publicacion.validarCliente('Cafetería Brisa'), isNull);
    });

    test('título de más de 150 caracteres no es válido', () {
      expect(Publicacion.validarTitulo('a' * 151), isNotNull);
    });

    test('texto de más de 2,200 caracteres no es válido', () {
      expect(Publicacion.validarTexto('a' * 2201), isNotNull);
      expect(Publicacion.validarTexto(''), isNull);
    });
  });

  group('Estado de la publicación', () {
    test('queda lista solo con los 5 puntos marcados', () {
      final todos = {
        for (final p in puntosRevision) p.clave: const EstadoPunto(hecho: true),
      };
      expect(Publicacion.calcularEstado(todos), 'listo');
    });

    test('sigue pendiente si falta un punto', () {
      final casi = {
        for (final p in puntosRevision) p.clave: const EstadoPunto(hecho: true),
      };
      casi['formato'] = const EstadoPunto(hecho: false);
      expect(Publicacion.calcularEstado(casi), 'pendiente');
    });

    test('la checklist nueva tiene los 5 puntos sin marcar', () {
      final vacio = Publicacion.checklistVacio();
      expect(vacio.length, 5);
      expect(vacio.values.every((v) => v['hecho'] == false), isTrue);
    });
  });
}
