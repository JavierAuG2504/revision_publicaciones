import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Colores de la app, tomados de los wireframes de la etapa 2.
class Colores {
  static const primario = Color(0xFF2D4BD1);
  static const primarioSuave = Color(0xFFE6EAFB);
  static const pendiente = Color(0xFFB76E12);
  static const pendienteSuave = Color(0xFFFCEFD9);
  static const listo = Color(0xFF1F7A52);
  static const listoSuave = Color(0xFFDDF3E8);
  static const fondo = Color(0xFFF5F6F8);
  static const texto = Color(0xFF1D2330);
  static const textoSecundario = Color(0xFF646B7A);
  static const borde = Color(0xFFE3E6EC);
}

ThemeData temaApp() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colores.primario,
        primary: Colores.primario,
      ),
      scaffoldBackgroundColor: Colores.fondo,
    );

AppBar barraSuperior(String titulo, {List<Widget>? acciones, bool mostrarAtras = true}) {
  return AppBar(
    title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
    backgroundColor: Colors.white,
    foregroundColor: Colores.texto,
    surfaceTintColor: Colors.white,
    automaticallyImplyLeading: mostrarAtras,
    actions: acciones,
  );
}

InputDecoration decoracionCampo(String etiqueta, {String? ayuda, Widget? sufijo}) {
  return InputDecoration(
    labelText: etiqueta,
    hintText: ayuda,
    suffixIcon: sufijo,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  );
}

String formatearFecha(DateTime fecha) =>
    DateFormat("EEE d 'de' MMM, HH:mm", 'es_MX').format(fecha);

/// Tarjeta blanca con borde, como en los wireframes.
class Tarjeta extends StatelessWidget {
  const Tarjeta({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colores.borde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Etiqueta de estado: amarilla para "Pendiente", verde para "Listo para publicar".
class PildoraEstado extends StatelessWidget {
  const PildoraEstado({super.key, required this.lista});

  final bool lista;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: lista ? Colores.listoSuave : Colores.pendienteSuave,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        lista ? 'Listo para publicar' : 'Pendiente',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: lista ? Colores.listo : Colores.pendiente,
        ),
      ),
    );
  }
}
