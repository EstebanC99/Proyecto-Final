import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Formulario para registrar un nuevo evento de salud (US-30).
///
/// El tipo de evento se selecciona desde el catálogo compartido con la agenda
/// ([tiposEventoProvider]). Un evento de salud es algo que ya ocurrió, por lo que
/// no se admiten fechas ni horas futuras.
class HealthEventFormScreen extends ConsumerStatefulWidget {
  const HealthEventFormScreen({super.key, this.eventId});

  /// Si no es null, se muestra como edición (futuro MVP).
  final int? eventId;

  @override
  ConsumerState<HealthEventFormScreen> createState() =>
      _HealthEventFormScreenState();
}

class _HealthEventFormScreenState extends ConsumerState<HealthEventFormScreen> {
  /// Id del tipo seleccionado. `null` hasta que carga el catálogo.
  int? _tipoId;
  final _descripcionCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();
  bool _loading = false;

  bool get _esEdicion => widget.eventId != null;

  /// Combina [_fecha] y [_hora] en un único [DateTime] con horas y minutos.
  DateTime get _fechaHora =>
      DateTime(_fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute);

  @override
  void initState() {
    super.initState();
    // El alta arranca en el día que el usuario tiene abierto en la tira, no en
    // hoy: si vino mirando otro día, ofrecerle la fecha de hoy es engañoso.
    // La selección nunca es futura (la pantalla de eventos la acota a hoy), así
    // que siempre cae dentro del rango admitido por el selector de fecha.
    _fecha = ref.read(diaEventosSaludSeleccionadoProvider);
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    // El diálogo es asíncrono: la pantalla puede haberse ido mientras estaba
    // abierto.
    if (picked == null || !mounted) return;
    setState(() => _fecha = picked);
    // Mover la fecha a hoy puede volver futura una hora que era válida ayer.
    _clampearSiEsFutura();
  }

  Future<void> _elegirHora() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked == null || !mounted) return;
    setState(() => _hora = picked);
    _clampearSiEsFutura();
  }

  /// Recorta la hora a "ahora" si la combinación fecha + hora cae en el futuro.
  ///
  /// Un evento de salud es algo que ya ocurrió. El recorte se avisa: antes era
  /// silencioso y el usuario elegía las 23:00, se guardaban las 15:22 y nadie
  /// se lo decía.
  void _clampearSiEsFutura() {
    if (!mounted) return;

    final ahora = DateTime.now();
    if (!_fechaHora.isAfter(ahora)) return;

    setState(() => _hora = TimeOfDay.fromDateTime(ahora));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Un evento de salud no puede ser futuro; se ajustó a la hora actual.',
        ),
      ),
    );
  }

  /// Hay algo que perder si ya se escribió la descripción. Elegir un tipo o
  /// mover la fecha es un toque que se rehace; el texto no.
  bool get _hayCambios => _descripcionCtrl.text.trim().isNotEmpty;

  Future<void> _guardar() async {
    final desc = _descripcionCtrl.text.trim();
    final tipoId = _tipoId;
    if (desc.isEmpty || tipoId == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(crearEventoSaludProvider)(
        tipoId: tipoId,
        descripcion: desc,
        fechaHora: _fechaHora,
      );
      if (mounted) {
        // La pantalla de eventos pasa a mostrar el día del evento registrado:
        // si es de otra semana, igual queda a la vista al volver.
        seleccionarDiaEventosSalud(ref, _fechaHora);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento registrado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiposAsync = ref.watch(tiposEventoProvider);

    // `animate: false` de animate_do no desactiva la animación: deja el
    // controller en 0, o sea el hijo invisible. Con las animaciones apagadas
    // hay que saltear el wrapper, no configurarlo.
    final sinAnimacion = MediaQuery.disableAnimationsOf(context);
    Widget animado(Widget child, int delayMs) => sinAnimacion
        ? child
        : FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: Duration(milliseconds: delayMs),
            from: 12,
            child: child,
          );

    return UnsavedChangesGuard(
      hayCambios: () => _hayCambios,
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: ContextAppBar(
          eyebrow: _esEdicion
              ? 'Editar evento de salud'
              : 'Nuevo evento de salud',
          // El formulario muestra a quién se le registra, pero no deja cambiar
          // de persona con los datos a medio cargar.
          seleccionable: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              animado(_tipoEvento(tiposAsync), 0),
              animado(
                FormTextField(
                  controller: _descripcionCtrl,
                  label: 'Descripción',
                  hintText: 'Describí el evento de salud...',
                  accent: context.colors.healthAccent,
                  enabled: !_loading,
                  maxLines: 8,
                ),
                50,
              ),
              animado(_cuandoOcurrio(), 100),
            ],
          ),
        ),
        // Sólo la barra depende del texto: sin esto, cada tecla redibujaría la
        // grilla de 13 tipos entera.
        bottomNavigationBar: animado(
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _descripcionCtrl,
            builder: (context, valor, _) {
              final tieneDesc = valor.text.trim().isNotEmpty;
              return FormBottomBar(
                label: 'Registrar evento',
                accent: context.colors.healthAccent,
                loading: _loading,
                onPressed: (tieneDesc && _tipoId != null) ? _guardar : null,
                hint: tieneDesc
                    ? null
                    : 'Completá la descripción para continuar',
              );
            },
          ),
          150,
        ),
      ),
    );
  }

  /// Bloque de selección del tipo de evento.
  Widget _tipoEvento(AsyncValue<List<TipoEvento>> tiposAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(
          text: 'Tipo de evento',
          required: true,
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
        ),
        tiposAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ),
          error: (err, _) => InlineErrorBanner(
            message: 'No se pudieron cargar los tipos de evento. $err',
          ),
          data: (tipos) {
            if (tipos.isEmpty) {
              return Text(
                'No hay tipos de evento disponibles.',
                style: TextStyle(color: context.colors.textSecondary),
              );
            }
            // El orden lo define el catálogo, no el backend: así "Otro" (el id
            // más alto) queda siempre al final.
            final ordenados = [...tipos]..sort((a, b) => a.id.compareTo(b.id));

            // Selección por defecto: el primer tile de la grilla.
            //
            // Acá se preselecciona siempre porque el alta es el único modo
            // implementado. Cuando se agregue la precarga de edición hay que
            // esperarla antes de caer al default, como hace HabitFormScreen:
            // si no, se ve saltar la selección al resolverse el evento.
            _tipoId ??= ordenados.first.id;

            return TypeTileGrid(
              options: [
                for (final tipo in ordenados)
                  TypeTileOption(
                    id: tipo.id,
                    label: tipo.descripcion,
                    icon: TipoEventoTheme.iconFor(tipo.id),
                    accent: TipoEventoTheme.accentFor(context, tipo.id),
                    container: TipoEventoTheme.containerFor(context, tipo.id),
                  ),
              ],
              selectedId: _tipoId,
              onChanged: (id) => setState(() => _tipoId = id),
              enabled: !_loading,
            );
          },
        ),
      ],
    );
  }

  /// Par fecha + hora bajo un único rótulo.
  ///
  /// Van sin marca de obligatorio: ambas arrancan con un valor y no se pueden
  /// vaciar, así que el asterisco no aportaría nada.
  Widget _cuandoOcurrio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(
          text: 'Cuándo ocurrió',
          padding: EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
        ),
        Row(
          children: [
            Expanded(
              child: PickerField.pill(
                icon: Icons.calendar_today_outlined,
                value: fechaCortaRelativa(_fecha),
                onTap: _loading ? null : _elegirFecha,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: PickerField.pill(
                icon: Icons.schedule_outlined,
                value: _hora.format(context),
                onTap: _loading ? null : _elegirHora,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
