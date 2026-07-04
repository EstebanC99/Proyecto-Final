import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Formulario de alta/edición de un evento de agenda (US-24).
///
/// [eventId] identifica el evento a editar; `null` indica alta. En edición, los
/// datos se precargan desde [ocurrenciasDelMesProvider] (limitación MVP: se toma
/// la ocurrencia del mes visualizado). La recurrencia solo se configura al crear;
/// al editar no se altera, en línea con [AgendaRepository.modificarEvento].
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

  bool get _esEdicion => widget.eventId != null;

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
            backgroundColor: AppColors.error,
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
      final ocurrencias = ref.watch(ocurrenciasDelMesProvider).valueOrNull;
      final ocu = ocurrencias
          ?.where((o) => o.eventoAgendaId == widget.eventId)
          .firstOrNull;
      if (ocu != null) {
        _prefillDesde(ocu);
        _prefilled = true;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar evento' : 'Nuevo evento'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
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
    );
  }

  Widget _buildForm(BuildContext context, List<TipoEvento> tipos) {
    // Selección de tipo por defecto (o el precargado en edición).
    _tipo ??= tipos.isNotEmpty ? tipos.first : null;
    final tieneTitulo = _tituloCtrl.text.trim().isNotEmpty;
    final puedeGuardar = tieneTitulo && _tipo != null && !_loading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tipo de evento.
          const _SectionLabel('Tipo de evento *'),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tipos.map((t) {
                final selected = t.id == _tipo?.id;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(t.descripcion),
                    selected: selected,
                    onSelected: _loading
                        ? null
                        : (_) => setState(() => _tipo = t),
                    selectedColor: TipoEventoTheme.accentFor(t.id),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Título.
          const _SectionLabel('Título *'),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _tituloCtrl,
            enabled: !_loading,
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Ej.: Control cardiológico',
              prefixIcon: const Icon(Icons.title_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Descripción.
          const _SectionLabel('Descripción'),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _descripcionCtrl,
            enabled: !_loading,
            minLines: 2,
            maxLines: 5,
            maxLength: 500,
            textAlignVertical: TextAlignVertical.top,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Notas adicionales (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Fecha y hora.
          Row(
            children: [
              Expanded(
                child: _PickerField(
                  label: 'Fecha *',
                  icon: Icons.calendar_today_outlined,
                  value: '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                  onTap: _loading ? null : _elegirFecha,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PickerField(
                  label: 'Hora *',
                  icon: Icons.schedule_outlined,
                  value: _hora.format(context),
                  onTap: _loading ? null : _elegirHora,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Duración.
          const _SectionLabel('Duración'),
          const SizedBox(height: AppSpacing.sm),
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
            activeThumbColor: AppColors.healthAccent,
            title: const Text(
              'Generar evento de salud',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Se registrará también en Mi Salud cuando ocurra.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Botón guardar.
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: FilledButton(
              onPressed: puedeGuardar ? _guardar : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _esEdicion ? 'Guardar cambios' : 'Crear evento',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
        const _SectionLabel('Se repite de manera:'),
        const SizedBox(height: AppSpacing.sm),
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
                          const _SectionLabel('Cada'),
                          const SizedBox(width: AppSpacing.md),
                          _IntervaloStepper(
                            valor: _intervalo,
                            onChanged: _loading
                                ? null
                                : (v) => setState(() => _intervalo = v),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            _unidadFrecuencia(_frecuencia!, _intervalo),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PickerField(
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              color: AppColors.surface,
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IntervaloStepper extends StatelessWidget {
  const _IntervaloStepper({required this.valor, required this.onChanged});

  final int valor;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outline),
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
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
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.remove_rounded,
              size: 20,
              color: puedeRestar
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
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
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              size: 20,
              color: puedeSumar
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
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
          activeThumbColor: AppColors.info,
          title: const Text(
            'Recordatorio',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: const Text(
            'Recibí una notificación antes del evento.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: activo
              ? Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildCarrusel(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildCarrusel() {
    final idx = _indices.indexOf(anticipacion ?? 0);
    final safeIdx = idx < 0 ? 0 : idx;
    final label = _opciones[_indices[safeIdx]]!;
    final enPrimero = safeIdx == 0;
    final enUltimo = safeIdx == _indices.length - 1;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.infoContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 28,
              color: enPrimero ? AppColors.textDisabled : AppColors.info,
            ),
            onPressed: enPrimero
                ? null
                : () => onAnticipacionChanged(_indices[safeIdx - 1]),
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.info,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: enUltimo ? AppColors.textDisabled : AppColors.info,
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
/// Mismo estilo visual que [_RecordatorioCarrusel]: fondo [AppColors.infoContainer],
/// texto y flechas en [AppColors.info], height 56, radio [AppSpacing.radiusMd].
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
        color: AppColors.infoContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 28,
              color: (enPrimero || onChanged == null)
                  ? AppColors.textDisabled
                  : AppColors.info,
            ),
            onPressed: (enPrimero || onChanged == null)
                ? null
                : () => onChanged!(_opciones[safeIdx - 1]),
          ),
          Expanded(
            child: Text(
              _label(_opciones[safeIdx]),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.info,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              size: 28,
              color: (enUltimo || onChanged == null)
                  ? AppColors.textDisabled
                  : AppColors.info,
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
