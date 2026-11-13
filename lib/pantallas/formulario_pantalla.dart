import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../modelos/publicacion.dart';
import '../servicios/publicaciones_servicio.dart';
import '../tema.dart';

/// Pantalla 4: formulario para crear (CREATE) o editar (UPDATE) una publicación.
class FormularioPantalla extends StatefulWidget {
  const FormularioPantalla({super.key, this.publicacion});

  /// Si es null, se crea una publicación nueva; si no, se edita esta.
  final Publicacion? publicacion;

  @override
  State<FormularioPantalla> createState() => _FormularioPantallaState();
}

class _FormularioPantallaState extends State<FormularioPantalla> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _cliente;
  late final TextEditingController _titulo;
  late final TextEditingController _texto;
  late String _red;
  late DateTime _fecha;
  bool _guardando = false;

  bool get _editando => widget.publicacion != null;

  @override
  void initState() {
    super.initState();
    final p = widget.publicacion;
    _cliente = TextEditingController(text: p?.cliente ?? '');
    _titulo = TextEditingController(text: p?.titulo ?? '');
    _texto = TextEditingController(text: p?.texto ?? '');
    _red = p?.redSocial ?? redesSociales.first;
    final manana = DateTime.now().add(const Duration(days: 1));
    _fecha = p?.fechaPublicacion ?? DateTime(manana.year, manana.month, manana.day, 10);
  }

  @override
  void dispose() {
    _cliente.dispose();
    _titulo.dispose();
    _texto.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (elegida != null) {
      setState(() => _fecha = DateTime(
            elegida.year, elegida.month, elegida.day, _fecha.hour, _fecha.minute));
    }
  }

  Future<void> _elegirHora() async {
    final elegida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fecha),
    );
    if (elegida != null) {
      setState(() => _fecha = DateTime(
            _fecha.year, _fecha.month, _fecha.day, elegida.hour, elegida.minute));
    }
  }

  Future<void> _guardar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() => _guardando = true);
    final servicio = PublicacionesServicio.instancia;
    try {
      if (_editando) {
        await servicio.actualizarDatos(
          id: widget.publicacion!.id,
          cliente: _cliente.text,
          titulo: _titulo.text,
          redSocial: _red,
          texto: _texto.text,
          fechaPublicacion: _fecha,
        );
      } else {
        await servicio.crear(
          cliente: _cliente.text,
          titulo: _titulo.text,
          redSocial: _red,
          texto: _texto.text,
          fechaPublicacion: _fecha,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: barraSuperior(_editando ? 'Editar publicación' : 'Nueva publicación'),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _cliente,
              decoration: decoracionCampo('Cliente', ayuda: 'Ej. Cafetería Brisa'),
              maxLength: 100,
              validator: Publicacion.validarCliente,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titulo,
              decoration: decoracionCampo('Título de la pieza', ayuda: 'Ej. Promo de fin de semana'),
              maxLength: 150,
              validator: Publicacion.validarTitulo,
            ),
            const SizedBox(height: 8),
            const Text('Red social', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                for (final red in redesSociales)
                  ChoiceChip(
                    label: Text(red),
                    selected: _red == red,
                    onSelected: (_) => setState(() => _red = red),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _elegirFecha,
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(DateFormat('dd/MM/yyyy').format(_fecha)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _elegirHora,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(DateFormat('HH:mm').format(_fecha)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _texto,
              decoration: decoracionCampo(
                'Texto de la publicación',
                ayuda: 'El copy que acompañará la pieza',
              ),
              minLines: 4,
              maxLines: 8,
              maxLength: 2200,
              validator: Publicacion.validarTexto,
            ),
            if (!_editando)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colores.primarioSuave,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'La publicación se crea con la checklist de 5 puntos sin marcar.',
                  style: TextStyle(color: Color(0xFF33449A), fontSize: 13),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _guardando ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
