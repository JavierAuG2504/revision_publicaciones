import 'package:flutter/material.dart';

import '../modelos/publicacion.dart';
import '../servicios/ia_servicio.dart';
import '../servicios/publicaciones_servicio.dart';
import '../tema.dart';
import 'formulario_pantalla.dart';

/// Pantalla 3: detalle de la publicación, checklist (UPDATE),
/// revisión con Gemini, edición y borrado (DELETE).
class DetallePantalla extends StatefulWidget {
  const DetallePantalla({super.key, required this.publicacionId});

  final String publicacionId;

  @override
  State<DetallePantalla> createState() => _DetallePantallaState();
}

class _DetallePantallaState extends State<DetallePantalla> {
  final _servicio = PublicacionesServicio.instancia;
  bool _revisandoIa = false;
  String? _resultadoIa;

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _marcar(Publicacion p, String clave, bool hecho) async {
    try {
      await _servicio.marcarPunto(p, clave, hecho);
    } catch (e) {
      _aviso('No se pudo guardar el cambio: $e');
    }
  }

  Future<void> _revisarConIa(Publicacion p) async {
    setState(() {
      _revisandoIa = true;
      _resultadoIa = null;
    });
    try {
      final resultado = await IaServicio.instancia.revisarOrtografia(p.texto);
      if (mounted) setState(() => _resultadoIa = resultado);
    } catch (e) {
      if (mounted) setState(() => _resultadoIa = 'No se pudo revisar con Gemini.\n$e');
    } finally {
      if (mounted) setState(() => _revisandoIa = false);
    }
  }

  Future<void> _eliminar(Publicacion p) async {
    if (!_servicio.esCreador(p)) {
      _aviso('Solo ${p.creadoPorNombre} puede eliminar esta publicación.');
      return;
    }
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: Text('¿Eliminar "${p.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await _servicio.eliminar(p.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _aviso('No se pudo eliminar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Publicacion?>(
      stream: _servicio.una(widget.publicacionId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: barraSuperior('Detalle de la publicación'),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: barraSuperior('Detalle de la publicación'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final p = snapshot.data;
        if (p == null) {
          return Scaffold(
            appBar: barraSuperior('Detalle de la publicación'),
            body: const Center(child: Text('Esta publicación ya no existe.')),
          );
        }
        return Scaffold(
          appBar: barraSuperior(
            'Detalle de la publicación',
            acciones: [
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => FormularioPantalla(publicacion: p)),
                ),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _eliminar(p),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _datos(p),
              const SizedBox(height: 12),
              _texto(p),
              const SizedBox(height: 12),
              _checklist(p),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colores.primarioSuave,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Al marcar los 5 puntos, la publicación cambia a "Listo para publicar" y se avisa a quien la creó.',
                  style: TextStyle(color: Color(0xFF33449A), fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _datos(Publicacion p) {
    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.cliente, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
          const SizedBox(height: 3),
          Text(p.titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${p.redSocial}, ${formatearFecha(p.fechaPublicacion)}',
                  style: const TextStyle(fontSize: 12, color: Colores.textoSecundario),
                ),
              ),
              PildoraEstado(lista: p.estaLista),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Creada por ${p.creadoPorNombre}',
            style: const TextStyle(fontSize: 12, color: Colores.textoSecundario),
          ),
        ],
      ),
    );
  }

  Widget _texto(Publicacion p) {
    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Texto de la publicación', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            p.texto.isEmpty ? 'Sin texto.' : p.texto,
            style: const TextStyle(height: 1.4),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: _revisandoIa || p.texto.isEmpty ? null : () => _revisarConIa(p),
            icon: _revisandoIa
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_revisandoIa ? 'Revisando…' : 'Revisar ortografía con IA'),
          ),
          if (_resultadoIa != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colores.fondo,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colores.borde),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sugerencias de Gemini',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(_resultadoIa!, style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 6),
                  const Text(
                    'Revisa las sugerencias antes de marcar "Ortografía revisada".',
                    style: TextStyle(fontSize: 12, color: Colores.textoSecundario),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _checklist(Publicacion p) {
    return Tarjeta(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final punto in puntosRevision)
            CheckboxListTile(
              value: p.checklist[punto.clave]?.hecho ?? false,
              onChanged: (v) => _marcar(p, punto.clave, v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(punto.nombre),
              subtitle: Text(
                (p.checklist[punto.clave]?.hecho ?? false)
                    ? 'Marcado por ${p.checklist[punto.clave]?.por ?? 'alguien'}'
                    : 'Sin revisar',
                style: const TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
