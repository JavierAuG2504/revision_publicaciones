import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../modelos/publicacion.dart';
import '../servicios/publicaciones_servicio.dart';
import '../tema.dart';
import 'detalle_pantalla.dart';
import 'formulario_pantalla.dart';

enum Filtro { todas, pendientes, listas }

/// Pantalla 2: lista de publicaciones (READ en tiempo real).
class ListaPantalla extends StatefulWidget {
  const ListaPantalla({super.key});

  @override
  State<ListaPantalla> createState() => _ListaPantallaState();
}

class _ListaPantallaState extends State<ListaPantalla> {
  Filtro _filtro = Filtro.todas;

  List<Publicacion> _filtrar(List<Publicacion> todas) {
    switch (_filtro) {
      case Filtro.todas:
        return todas;
      case Filtro.pendientes:
        return todas.where((p) => !p.estaLista).toList();
      case Filtro.listas:
        return todas.where((p) => p.estaLista).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;
    final nombre = usuario == null ? '' : PublicacionesServicio.nombreDe(usuario);
    final iniciales = nombre.isEmpty ? '?' : nombre.substring(0, nombre.length >= 2 ? 2 : 1).toUpperCase();

    return Scaffold(
      appBar: barraSuperior(
        'Publicaciones',
        mostrarAtras: false,
        acciones: [
          PopupMenuButton<String>(
            tooltip: 'Cuenta',
            onSelected: (valor) {
              if (valor == 'salir') FirebaseAuth.instance.signOut();
            },
            itemBuilder: (_) => [
              PopupMenuItem(enabled: false, child: Text(usuario?.email ?? '')),
              const PopupMenuItem(value: 'salir', child: Text('Cerrar sesión')),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Colores.primarioSuave,
                child: Text(
                  iniciales,
                  style: const TextStyle(
                    color: Colores.primario,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FormularioPantalla()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nueva publicación'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Wrap(
              spacing: 8,
              children: [
                _chip('Todas', Filtro.todas),
                _chip('Pendientes', Filtro.pendientes),
                _chip('Listas', Filtro.listas),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Publicacion>>(
              stream: PublicacionesServicio.instancia.todas(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _mensaje('No se pudieron cargar las publicaciones.\n${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lista = _filtrar(snapshot.data!);
                if (lista.isEmpty) {
                  return _mensaje(_filtro == Filtro.todas
                      ? 'Aún no hay publicaciones.\nCrea la primera con el botón "Nueva publicación".'
                      : 'No hay publicaciones con este filtro.');
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: lista.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) => _TarjetaPublicacion(lista[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String texto, Filtro filtro) {
    return ChoiceChip(
      label: Text(texto),
      selected: _filtro == filtro,
      onSelected: (_) => setState(() => _filtro = filtro),
    );
  }

  Widget _mensaje(String texto) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colores.textoSecundario),
        ),
      ),
    );
  }
}

class _TarjetaPublicacion extends StatelessWidget {
  const _TarjetaPublicacion(this.publicacion);

  final Publicacion publicacion;

  @override
  Widget build(BuildContext context) {
    final p = publicacion;
    final total = puntosRevision.length;
    return Tarjeta(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DetallePantalla(publicacionId: p.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(p.cliente, style: const TextStyle(fontSize: 12, color: Colores.textoSecundario)),
          const SizedBox(height: 3),
          Text(p.titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: p.puntosHechos / total,
              minHeight: 5,
              backgroundColor: Colores.borde,
              color: p.estaLista ? Colores.listo : Colores.primario,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${p.puntosHechos} de $total puntos revisados',
            style: const TextStyle(fontSize: 12, color: Colores.textoSecundario),
          ),
        ],
      ),
    );
  }
}
