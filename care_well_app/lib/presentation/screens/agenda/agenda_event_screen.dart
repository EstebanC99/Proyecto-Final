import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Formulario de alta/edición de un evento de agenda (US-24).
///
/// [eventId] identifica el evento a editar; `null` indica alta. En edición, los
/// datos se precargan desde [ocurrenciasDeSemanaProvider]: a la edición solo se
/// llega tocando un evento del día visible en la agenda, que siempre pertenece
/// a la semana cargada. La recurrencia solo se configura al crear; al editar no
/// se altera, en línea con [AgendaRepository.modificarEvento].
class AgendaEventScreen extends ConsumerStatefulWidget {
  const AgendaEventScreen({super.key, this.eventId});

  final int? eventId;

  @override
  ConsumerState<AgendaEventScreen> createState() => _AgendaEventScreenState();
}

class _AgendaEventScreenState extends ConsumerState<AgendaEventScreen> {
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  TipoEvento? _tipo;
  DateTime _fecha = DateTime.now();
  TimeOfDay _hora = TimeOfDay.now();
  int _duracion = 0;
  int? _anticipacion;
  bool _generarEventoSalud = true;

  // Recurrencia (solo alta). null = "Nunca" (sin recurrencia).
  FrecuenciaRecurrencia? _frecuencia;
  int _intervalo = 1;
  DateTime? _fechaFin;

  bool get _esRecurrente => _frecuencia != null;

  bool _loading = false;
  bool _prefilled = false;

  /// La búsqueda de la ocurrencia a editar ya terminó, la haya encontrado o no.
  ///
  /// Habilita el fallback al primer tipo del catálogo. Es "intentada" y no
  /// "lograda" a propósito: si la ocurrencia no aparece (evento de otra semana,
  /// lista vacía), el formulario igual necesita un tipo elegido o el botón de
  /// guardar queda bloqueado para siempre.
  bool _precargaIntentada = false;

  bool get _esEdicion => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    // El alta arranca en el día que el usuario tiene abierto en la tira, no en
    // hoy: si vino mirando otra semana, ofrecerle la fecha de hoy es engañoso.
    // En edición manda la ocurrencia, que se precarga en `build`.
    if (!_esEdicion) {
      final seleccionado = ref.read(diaSeleccionadoProvider);
      final hoy = DateTime.now();
      final inicioDeHoy = DateTime(hoy.year, hoy.month, hoy.day);
      // La agenda no admite eventos pasados (ver `firstDate` del selector de
      // fecha): parado en una semana anterior, el alta cae en hoy.
      _fecha = seleccionado.isBefore(inicioDeHoy) ? inicioDeHoy : seleccionado;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  /// Precarga los campos a partir de una ocurrencia existente (edición).
  void _prefillDesde(OcurrenciaEventoAgenda ocu) {
    _tituloCtrl.text = ocu.titulo;
    _descripcionCtrl.text = ocu.descripcion ?? '';
    _tipo = ocu.tipo;
    final inicio = ocu.fechaHoraInicio.toLocal();
    _fecha = inicio;
    _hora = TimeOfDay(hour: inicio.hour, minute: inicio.minute);
    _duracion = ocu.fechaHoraFin.difference(ocu.fechaHoraInicio).inMinutes;
    _anticipacion = ocu.minutosAnticipacionRecordatorio;
    _generarEventoSalud = ocu.generarEventoSalud;
  }

  Future<void> _elegirFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _elegirHora() async {
    final picked = await showTimePicker(context: context, initialTime: _hora);
    if (picked != null) setState(() => _hora = picked);
  }

  Future<void> _elegirFechaFin() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFin ?? _fecha.add(const Duration(days: 30)),
      firstDate: _fecha,
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) setState(() => _fechaFin = picked);
  }

  DateTime get _fechaHoraInicio =>
      DateTime(_fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute);

  Future<void> _guardar() async {
    final titulo = _tituloCtrl.text.trim();
    final tipo = _tipo;
    if (titulo.isEmpty || tipo == null) return;

    final descripcion = _descripcionCtrl.text.trim();
    final descripcionOpt = descripcion.isEmpty ? null : descripcion;

    setState(() => _loading = true);
    try {
      if (_esEdicion) {
        await ref.read(modificarEventoAgendaProvider)(
          eventoAgendaId: widget.eventId!,
          titulo: titulo,
          descripcion: descripcionOpt,
          tipoEventoId: tipo.id,
          fechaHoraInicio: _fechaHoraInicio,
          duracionMinutos: _duracion,
          generarEventoSalud: _generarEventoSalud,
          minutosAnticipacionRecordatorio: _anticipacion,
        );
      } else {
        final persona = await ref.read(agendaPersonaContextProvider.future);
        final personaId = persona?.id;
        if (personaId == null) {
          throw StateError('No hay persona de contexto para crear el evento.');
        }
        await ref.read(crearEventoAgendaProvider)(
          personaId: personaId,
          titulo: titulo,
          descripcion: descripcionOpt,
          tipoEventoId: tipo.id,
          fechaHoraInicio: _fechaHoraInicio,
          duracionMinutos: _duracion,
          generarEventoSalud: _generarEventoSalud,
          minutosAnticipacionRecordatorio: _anticipacion,
          frecuenciaRecurrenciaId: _frecuencia?.id,
          intervaloRecurrencia: _esRecurrente ? _intervalo : null,
          fechaFinRecurrencia: _esRecurrente ? _fechaFin : null,
        );
      }
      if (mounted) {
        // La agenda pasa a mostrar el día del evento guardado: si se creó (o se
        // movió) a otra semana, igual queda a la vista al volver.
        seleccionarDiaAgenda(ref, _fechaHoraInicio);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _esEdicion ? 'Evento actualizado' : 'Evento creado correctamente',
            ),
          ),
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
    final tiposAsync = ref.watch(tiposEventoAgendablesProvider);

    // Precarga de datos en edición (una sola vez, al disponer de las ocurrencias).
    if (_esEdicion && !_prefilled) {
      final ocurrenciasAsync = ref.watch(ocurrenciasDeSemanaProvider);
      if (!ocurrenciasAsync.isLoading) {
        final ocu = ocurrenciasAsync.value
            ?.where((o) => o.eventoAgendaId == widget.eventId)
            .firstOrNull;
        if (ocu != null) {
          _prefillDesde(ocu);
          _prefilled = true;
        }
        // Marca el intento aunque no se haya encontrado nada: recién ahí el
        // formulario puede caer al tipo por defecto sin pisar el precargado.
        _precargaIntentada = true;
      }
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: ContextAppBar(
        eyebrow: _esEdicion ? 'Editar evento' : 'Nuevo evento',
        // El formulario muestra a quién se le agenda, pero no deja cambiar de
        // persona con los datos a medio cargar.
        seleccionable: false,
      ),
      body: tiposAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: InlineErrorBanner(
              message: 'No se pudieron cargar los tipos de evento. $err',
            ),
          ),
        ),
        data: (tipos) => _buildForm(context, tipos),
      ),
      // Sólo el botón depende del título: escuchando el controller acá, en vez
      // de reconstruir la pantalla en cada tecla, no se redibujan la grilla de
      // tipos, los steppers ni los carruseles al tipear.
      bottomNavigationBar: _animado(
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _tituloCtrl,
          builder: (context, valor, _) {
            final tieneTitulo = valor.text.trim().isNotEmpty;
            return FormBottomBar(
              label: _esEdicion ? 'Guardar cambios' : 'Crear evento',
              accent: context.colors.primary,
              loading: _loading,
              onPressed: (tieneTitulo && _tipo != null) ? _guardar : null,
              hint: tieneTitulo ? null : 'Completá el título para continuar',
            );
          },
        ),
        200,
      ),
    );
  }

  /// Borde del campo de título, al mismo estilo que [DescriptionField].
  OutlineInputBorder _bordeCampo(Color color, {double ancho = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  /// Envuelve un bloque del formulario en la animación de entrada.
  ///
  /// `animate: false` de animate_do no desactiva la animación: deja el
  /// controller en 0, o sea el hijo invisible. Con las animaciones apagadas hay
  /// que saltear el wrapper, no configurarlo.
  Widget _animado(Widget child, int delayMs) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: delayMs),
      from: 12,
      child: child,
    );
  }

  Widget _buildForm(BuildContext context, List<TipoEvento> tipos) {
    // El orden lo define el catálogo, no el backend: así "Otro" (el id más
    // alto) queda siempre al final.
    final ordenados = [...tipos]..sort((a, b) => a.id.compareTo(b.id));

    // Selección por defecto: el primer tile de la grilla.
    //
    // En edición se espera a que termine la búsqueda de la ocurrencia: si no,
    // el primer frame pinta el tile 1 elegido y la selección salta a otro tile
    // a la vista del usuario cuando resuelven las ocurrencias.
    if (_tipo == null &&
        ordenados.isNotEmpty &&
        (!_esEdicion || _precargaIntentada)) {
      _tipo = ordenados.first;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de evento.
          _animado(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel(
                  text: 'Tipo de evento',
                  required: true,
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                ),
                TypeTileGrid(
                  options: [
                    for (final tipo in ordenados)
                      TypeTileOption(
                        id: tipo.id,
                        label: tipo.descripcion,
                        icon: TipoEventoTheme.iconFor(tipo.id),
                        accent: TipoEventoTheme.accentFor(context, tipo.id),
                        container: TipoEventoTheme.containerFor(
                          context,
                          tipo.id,
                        ),
                      ),
                  ],
                  selectedId: _tipo?.id,
                  // La grilla emite el id; el resto del formulario trabaja con
                  // la entidad (`_guardar` usa `tipo.id`), así que se resuelve
                  // acá en vez de cambiar el tipo del estado.
                  onChanged: (id) => setState(
                    () => _tipo = ordenados.firstWhere((t) => t.id == id),
                  ),
                  enabled: !_loading,
                ),
              ],
            ),
            0,
          ),

          // Título. Se deja con el contador nativo: es de una línea y el campo
          // no se repite en ninguna otra pantalla.
          _animado(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel(
                  text: 'Título',
                  required: true,
                  padding: EdgeInsets.only(
                    top: AppSpacing.xl,
                    bottom: AppSpacing.sm,
                  ),
                ),
                TextFormField(
                  controller: _tituloCtrl,
                  enabled: !_loading,
                  maxLength: 120,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ej.: Control cardiológico',
                    filled: true,
                    fillColor: context.colors.surface,
                    border: _bordeCampo(context.colors.outline),
                    enabledBorder: _bordeCampo(context.colors.outline),
                    disabledBorder: _bordeCampo(context.colors.outline),
                    focusedBorder: _bordeCampo(
                      context.colors.primary,
                      ancho: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            50,
          ),

          // Descripción: el único campo opcional de los tres formularios.
          _animado(
            DescriptionField(
              controller: _descripcionCtrl,
              label: 'Descripción',
              hintText: 'Notas adicionales (opcional)',
              accent: context.colors.primary,
              enabled: !_loading,
              required: false,
              minLines: 2,
              maxLines: 5,
              labelPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
            ),
            100,
          ),

          // Cuándo: fecha y hora bajo un único rótulo. Van sin marca de
          // obligatorio porque ambas arrancan con valor y no se pueden vaciar.
          _animado(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel(
                  text: 'Cuándo',
                  padding: EdgeInsets.only(
                    top: AppSpacing.xl,
                    bottom: AppSpacing.sm,
                  ),
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
            ),
            150,
          ),
          const SizedBox(height: AppSpacing.lg),
          const SizedBox(height: AppSpacing.lg),

          // Duración.
          const SectionLabel(
            text: 'Duración',
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
          ),
          _DuracionStepper(
            valor: _duracion,
            onChanged: _loading ? null : (v) => setState(() => _duracion = v),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Recordatorio.
          _RecordatorioCarrusel(
            activo: _anticipacion != null,
            anticipacion: _anticipacion,
            onActivoChanged: _loading
                ? null
                : (v) => setState(() => _anticipacion = v ? 0 : null),
            onAnticipacionChanged: (v) => setState(() => _anticipacion = v),
          ),
          const SizedBox(height: AppSpacing.md),

          // Recurrencia (solo alta): la edición nunca recibe eventos recurrentes.
          if (!_esEdicion) ...[
            const Divider(height: AppSpacing.xl),
            _buildRecurrencia(),
            const SizedBox(height: AppSpacing.md),
          ],

          // Generar evento de salud.
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _generarEventoSalud,
            onChanged: _loading
                ? null
                : (v) => setState(() => _generarEventoSalud = v),
            activeThumbColor: context.colors.healthAccent,
            title: Text(
              'Generar evento de salud',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            subtitle: Text(
              'Se registrará también en Mi Salud cuando ocurra.',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurrencia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel(
          text: 'Se repite de manera',
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
        ),
        _FrecuenciaCarrusel(
          frecuencia: _frecuencia,
          onChanged: _loading
              ? null
              : (f) => setState(() {
                  _frecuencia = f;
                  if (f == null) {
                    _intervalo = 1;
                    _fechaFin = null;
                  }
                }),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _frecuencia != null
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SectionLabel(
                            text: 'Cada',
                            padding: EdgeInsets.only(right: AppSpacing.md),
                          ),
                          _IntervaloStepper(
                            valor: _intervalo,
                            onChanged: _loading
                                ? null
                                : (v) => setState(() => _intervalo = v),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _unidadFrecuencia(_frecuencia!, _intervalo),
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PickerField(
                        label: 'Hasta (opcional)',
                        icon: Icons.event_available_outlined,
                        value: _fechaFin == null
                            ? 'Sin fecha de fin'
                            : '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}',
                        onTap: _loading ? null : _elegirFechaFin,
                        trailing: _fechaFin == null
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: _loading
                                    ? null
                                    : () => setState(() => _fechaFin = null),
                              ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  static String _unidadFrecuencia(FrecuenciaRecurrencia f, int intervalo) {
    final plural = intervalo > 1;
    return switch (f) {
      FrecuenciaRecurrencia.diaria => plural ? 'días' : 'día',
      FrecuenciaRecurrencia.semanal => plural ? 'semanas' : 'semana',
      FrecuenciaRecurrencia.mensual => plural ? 'meses' : 'mes',
    };
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _IntervaloStepper extends StatelessWidget {
  const _IntervaloStepper({required this.valor, required this.onChanged});

  final int valor;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: (onChanged == null || valor <= 1)
                ? null
                : () => onChanged!(valor - 1),
          ),
          Text(
            '$valor',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: (onChanged == null || valor >= 99)
                ? null
                : () => onChanged!(valor + 1),
          ),
        ],
      ),
    );
  }
}

class _DuracionStepper extends StatelessWidget {
  const _DuracionStepper({required this.valor, this.onChanged});

  final int valor;
  final ValueChanged<int>? onChanged;

  static const int _min = 0;
  static const int _max = 480;
  static const int _step = 15;

  String _label() {
    if (valor <= 0) return '0 min';
    if (valor < 60) return '$valor min';
    final h = valor ~/ 60;
    final m = valor % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final puedeRestar = onChanged != null && valor > _min;
    final puedeSumar = onChanged != null && valor < _max;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        color: context.colors.surface,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.remove_rounded,
              size: 20,
              color: puedeRestar
                  ? context.colors.textPrimary
                  : context.colors.textDisabled,
            ),
            onPressed: puedeRestar ? () => onChanged!(valor - _step) : null,
          ),
          Expanded(
            child: Text(
              _label(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valor == 0
                    ? context.colors.textSecondary
                    : context.colors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              size: 20,
              color: puedeSumar
                  ? context.colors.textPrimary
                  : context.colors.textDisabled,
            ),
            onPressed: puedeSumar ? () => onChanged!(valor + _step) : null,
          ),
        ],
      ),
    );
  }
}

class _RecordatorioCarrusel extends StatelessWidget {
  const _RecordatorioCarrusel({
    required this.activo,
    required this.anticipacion,
    this.onActivoChanged,
    required this.onAnticipacionChanged,
  });

  final bool activo;
  final int? anticipacion;
  final ValueChanged<bool>? onActivoChanged;
  final ValueChanged<int> onAnticipacionChanged;

  static const Map<int, String> _opciones = {
    0: 'Al inicio',
    15: '15 min antes',
    30: '30 min antes',
    60: '1 h antes',
    120: '2 h antes',
    1440: '1 día antes',
  };
  static final List<int> _indices = _opciones.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: activo,
          onChanged: onActivoChanged,
          activeThumbColor: context.colors.info,
          title: Text(
            'Recordatorio',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          subtitle: Text(
            'Recibí una notificación antes del evento.',
            style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: activo
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildCarrusel(context),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCarrusel(BuildContext context) {
    final idx = _indices.indexOf(anticipacion ?? 0);
    final safeIdx = idx < 0 ? 0 : idx;
    final label = _opciones[_indices[safeIdx]]!;
    final enPrimero = safeIdx == 0;
    final enUltimo = safeIdx == _indices.length - 1;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.colors.infoContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 28,
              color: enPrimero
                  ? context.colors.textDisabled
                  : context.colors.info,
            ),
            onPressed: enPrimero
                ? null
                : () => onAnticipacionChanged(_indices[safeIdx - 1]),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.colors.info,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: enUltimo
                  ? context.colors.textDisabled
                  : context.colors.info,
            ),
            onPressed: enUltimo
                ? null
                : () => onAnticipacionChanged(_indices[safeIdx + 1]),
          ),
        ],
      ),
    );
  }
}

/// Carrusel de selección de frecuencia de recurrencia.
///
/// Presenta cuatro posiciones: "Nunca" (null) → Diaria → Semanal → Mensual.
/// Mismo estilo visual que [_RecordatorioCarrusel]: fondo [AppPalette.infoContainer],
/// texto y flechas en [AppPalette.info], height 56, radio [AppSpacing.radiusMd].
/// Las flechas se deshabilitan en los extremos del rango y cuando [onChanged] es null.
class _FrecuenciaCarrusel extends StatelessWidget {
  const _FrecuenciaCarrusel({required this.frecuencia, this.onChanged});

  final FrecuenciaRecurrencia? frecuencia;

  /// Null deshabilita ambas flechas (estado loading del formulario padre).
  final ValueChanged<FrecuenciaRecurrencia?>? onChanged;

  // Orden fijo: null = Nunca, luego los valores del enum en progresión natural.
  static const List<FrecuenciaRecurrencia?> _opciones = [
    null,
    FrecuenciaRecurrencia.diaria,
    FrecuenciaRecurrencia.semanal,
    FrecuenciaRecurrencia.mensual,
  ];

  static String _label(FrecuenciaRecurrencia? f) => switch (f) {
    null => 'Nunca',
    FrecuenciaRecurrencia.diaria => 'Diaria',
    FrecuenciaRecurrencia.semanal => 'Semanal',
    FrecuenciaRecurrencia.mensual => 'Mensual',
  };

  @override
  Widget build(BuildContext context) {
    final idx = _opciones.indexOf(frecuencia);
    final safeIdx = idx < 0 ? 0 : idx;
    final enPrimero = safeIdx == 0;
    final enUltimo = safeIdx == _opciones.length - 1;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: context.colors.infoContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 28,
              color: (enPrimero || onChanged == null)
                  ? context.colors.textDisabled
                  : context.colors.info,
            ),
            onPressed: (enPrimero || onChanged == null)
                ? null
                : () => onChanged!(_opciones[safeIdx - 1]),
          ),
          Expanded(
            child: Text(
              _label(_opciones[safeIdx]),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.colors.info,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: (enUltimo || onChanged == null)
                  ? context.colors.textDisabled
                  : context.colors.info,
            ),
            onPressed: (enUltimo || onChanged == null)
                ? null
                : () => onChanged!(_opciones[safeIdx + 1]),
          ),
        ],
      ),
    );
  }
}
