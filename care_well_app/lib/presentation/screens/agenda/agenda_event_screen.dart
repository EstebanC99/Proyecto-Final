import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/shared/confirm_dialog.dart';
import '../../widgets/shared/inline_error_banner.dart';
import '../../widgets/shared/primary_button.dart';
import '../../widgets/shared/success_view.dart';

/// Pantalla de alta, edición y visualización de un evento de agenda.
///
/// - Modo alta ([eventId] == null): formulario en blanco.
/// - Modo edición ([eventId] != null, evento futuro): formulario pre-cargado.
/// - Modo readonly ([eventId] != null, evento vencido): campos deshabilitados,
///   banner informativo, sin botón eliminar.
class AgendaEventScreen extends ConsumerStatefulWidget {
  const AgendaEventScreen({super.key, this.eventId});

  final int? eventId;

  @override
  ConsumerState<AgendaEventScreen> createState() => _AgendaEventScreenState();
}

class _AgendaEventScreenState extends ConsumerState<AgendaEventScreen> {
  // ─── Estado del formulario ────────────────────────────────────────────────

  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();

  DateTime? _fecha;
  TimeOfDay? _hora;
  bool _conRecordatorio = true;

  bool _guardado = false;
  bool _cargando = false;
  String? _errorGlobal;

  // Estado previo para detectar cambios (PopScope)
  bool _hayDatosIngresados = false;

  // Evento cargado en modo edición/readonly
  EventoAgenda? _eventoOriginal;
  bool _inicializado = false;

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  // ─── Inicialización desde evento existente ────────────────────────────────

  void _inicializarDesdeEvento(EventoAgenda evento) {
    if (_inicializado) return;
    _inicializado = true;
    _eventoOriginal = evento;

    final dt = evento.fechaHoraInicio.toLocal();
    _fecha = DateTime(dt.year, dt.month, dt.day);
    _hora = TimeOfDay(hour: dt.hour, minute: dt.minute);
    _descripcionController.text = evento.titulo;
  }

  void _inicializarRecordatorio(List<Recordatorio> recordatorios) {
    if (!_inicializado) return;
    if (_eventoOriginal == null) return;
    // Solo actualizar si aún no se tocó el toggle manualmente.
    setState(() {
      _conRecordatorio = recordatorios.isNotEmpty;
    });
  }

  // ─── Pickers ─────────────────────────────────────────────────────────────

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('es'),
    );
    if (picked != null) {
      setState(() {
        _fecha = picked;
        _hayDatosIngresados = true;
      });
    }
  }

  Future<void> _pickHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _hora = picked;
        _hayDatosIngresados = true;
      });
    }
  }

  // ─── Validación ───────────────────────────────────────────────────────────

  String? _validarDescripcion(String? v) {
    if (v == null || v.trim().isEmpty) return 'La descripción es obligatoria.';
    if (v.trim().length < 3) return 'Mínimo 3 caracteres.';
    if (v.trim().length > 200) return 'Máximo 200 caracteres.';
    return null;
  }

  String? _validarFecha() {
    if (_fecha == null) return 'Seleccioná una fecha.';
    final hoy = DateTime.now();
    final hoyTruncado = DateTime(hoy.year, hoy.month, hoy.day);
    if (_fecha!.isBefore(hoyTruncado)) {
      return 'La fecha no puede ser en el pasado.';
    }
    return null;
  }

  String? _validarHora() {
    if (_hora == null) return 'Seleccioná una hora.';
    return null;
  }

  DateTime? _buildFechaHora() {
    if (_fecha == null || _hora == null) return null;
    return DateTime(
      _fecha!.year,
      _fecha!.month,
      _fecha!.day,
      _hora!.hour,
      _hora!.minute,
    );
  }

  // ─── Formateo ─────────────────────────────────────────────────────────────

  String _formatFecha(DateTime? d) {
    if (d == null) return 'Seleccionar fecha';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatHora(TimeOfDay? t) {
    if (t == null) return 'Seleccionar hora';
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  // ─── Acciones ─────────────────────────────────────────────────────────────

  Future<void> _crearEvento() async {
    setState(() => _errorGlobal = null);

    // Validaciones manuales de fecha y hora
    final errFecha = _validarFecha();
    final errHora = _validarHora();
    if (!_formKey.currentState!.validate() ||
        errFecha != null ||
        errHora != null) {
      setState(() {
        _errorGlobal = errFecha ?? errHora;
      });
      return;
    }

    final fechaHora = _buildFechaHora()!;
    final usuario = ref.read(authStateProvider).valueOrNull;
    final persona = ref.read(agendaPersonaContextProvider).valueOrNull;

    if (usuario == null || persona == null) {
      setState(() => _errorGlobal = 'Error de sesión. Volvé a intentarlo.');
      return;
    }

    setState(() => _cargando = true);
    try {
      await ref.read(crearEventoAgendaProvider)(
        personaCuidada: persona,
        fechaHora: fechaHora,
        descripcion: _descripcionController.text.trim(),
        conRecordatorio: _conRecordatorio,
        creadoPor: usuario,
      );
      if (mounted) setState(() => _guardado = true);
    } catch (e) {
      if (mounted) {
        setState(() => _errorGlobal = 'No se pudo crear el evento. $e');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _guardarCambios(EventoAgenda evento) async {
    setState(() => _errorGlobal = null);

    final errFecha = _validarFecha();
    final errHora = _validarHora();
    if (!_formKey.currentState!.validate() ||
        errFecha != null ||
        errHora != null) {
      setState(() {
        _errorGlobal = errFecha ?? errHora;
      });
      return;
    }

    final fechaHora = _buildFechaHora()!;

    setState(() => _cargando = true);
    try {
      await ref.read(actualizarEventoAgendaProvider)(
        evento: evento,
        descripcion: _descripcionController.text.trim(),
        fechaHora: fechaHora,
        conRecordatorio: _conRecordatorio,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Cambios guardados')),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _errorGlobal = 'No se pudo guardar. $e');
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _eliminarEvento(EventoAgenda evento) async {
    final confirmado = await ConfirmDialog.show(
      context,
      title: '¿Eliminar evento?',
      body: 'Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      icon: Icons.delete_outline,
      onConfirm: () async {
        await ref.read(eliminarEventoAgendaProvider)(evento);
      },
    );

    if (!mounted) return;
    if (confirmado) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Evento eliminado')));
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(AppRoutes.agendaName);
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Modo alta
    if (widget.eventId == null) {
      return _buildAlta();
    }

    // Modo edición o readonly: esperar el evento
    final eventoAsync = ref.watch(agendaEventoByIdProvider(widget.eventId!));

    return eventoAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: InlineErrorBanner(
            message: 'No se pudo cargar el evento. $err',
          ),
        ),
      ),
      data: (evento) {
        if (evento == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Evento no encontrado')),
            body: const Center(
              child: Text('El evento no existe o fue eliminado.'),
            ),
          );
        }

        // Inicializar formulario con datos del evento
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_inicializado) {
            setState(() => _inicializarDesdeEvento(evento));

            // Inicializar toggle de recordatorio
            ref.read(recordatoriosByEventoProvider(evento.id).future).then((
              recordatorios,
            ) {
              if (mounted) {
                setState(() => _inicializarRecordatorio(recordatorios));
              }
            });
          }
        });

        if (evento.estaVencido()) {
          return _buildReadonly(evento);
        }

        return _buildEdicion(evento);
      },
    );
  }

  // ─── Modo alta ────────────────────────────────────────────────────────────

  Widget _buildAlta() {
    if (_guardado) {
      return SuccessView(
        title: 'Evento creado',
        subtitle: ' fue agregado a la agenda.',
        highlightedName: _descripcionController.text.trim(),
        primaryButtonLabel: 'Ver agenda',
        onPrimaryTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoutes.agendaName);
          }
        },
      );
    }

    return PopScope(
      canPop: !_hayDatosIngresados,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final salir = await ConfirmDialog.show(
          context,
          title: '¿Salir sin guardar?',
          body: 'Los datos ingresados se perderán.',
          confirmLabel: 'Salir',
          icon: Icons.exit_to_app_outlined,
          onConfirm: () async {},
        );
        if (salir) nav.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Nuevo evento'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: _buildFormulario(
          readonly: false,
          onSubmit: _crearEvento,
          submitLabel: 'Crear evento',
        ),
      ),
    );
  }

  // ─── Modo edición ─────────────────────────────────────────────────────────

  Widget _buildEdicion(EventoAgenda evento) {
    final puedeGestionar =
        ref.watch(puedeGestionarAgendaProvider).valueOrNull ?? false;

    return PopScope(
      canPop: !_hayDatosIngresados,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final salir = await ConfirmDialog.show(
          context,
          title: '¿Salir sin guardar?',
          body: 'Los cambios no guardados se perderán.',
          confirmLabel: 'Salir',
          icon: Icons.exit_to_app_outlined,
          onConfirm: () async {},
        );
        if (salir) nav.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(evento.titulo),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          actions: [
            if (puedeGestionar)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Eliminar evento',
                color: AppColors.error,
                onPressed: () => _eliminarEvento(evento),
              ),
          ],
        ),
        body: _buildFormulario(
          readonly: false,
          onSubmit: () => _guardarCambios(evento),
          submitLabel: 'Guardar cambios',
        ),
      ),
    );
  }

  // ─── Modo readonly ────────────────────────────────────────────────────────

  Widget _buildReadonly(EventoAgenda evento) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(evento.titulo),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _buildFormulario(
        readonly: true,
        onSubmit: null,
        submitLabel: 'Guardar cambios',
        bannerReadonly: true,
      ),
    );
  }

  // ─── Formulario compartido ────────────────────────────────────────────────

  Widget _buildFormulario({
    required bool readonly,
    required VoidCallback? onSubmit,
    required String submitLabel,
    bool bannerReadonly = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner evento vencido
            if (bannerReadonly)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Este evento ya ocurrió y no puede modificarse.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Error global
            if (_errorGlobal != null) ...[
              InlineErrorBanner(message: _errorGlobal!),
              const SizedBox(height: AppSpacing.md),
            ],

            // Fecha
            _SelectorField(
              label: 'Fecha',
              value: _formatFecha(_fecha),
              icon: Icons.calendar_today_outlined,
              enabled: !readonly,
              onTap: readonly ? null : _pickFecha,
            ),
            const SizedBox(height: AppSpacing.md),

            // Hora
            _SelectorField(
              label: 'Hora',
              value: _formatHora(_hora),
              icon: Icons.schedule_outlined,
              enabled: !readonly,
              onTap: readonly ? null : _pickHora,
            ),
            const SizedBox(height: AppSpacing.md),

            // Descripción
            TextFormField(
              controller: _descripcionController,
              enabled: !readonly,
              maxLines: 3,
              maxLength: 200,
              textAlignVertical: TextAlignVertical.top,
              onChanged: (_) => setState(() => _hayDatosIngresados = true),
              validator: _validarDescripcion,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej: Consulta cardiológica con Dr. García',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Toggle recordatorio
            _RecordatorioToggle(
              value: _conRecordatorio,
              enabled: !readonly,
              onChanged: readonly
                  ? null
                  : (v) => setState(() {
                      _conRecordatorio = v;
                      _hayDatosIngresados = true;
                    }),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Botón submit
            PrimaryButton(
              label: submitLabel,
              isLoading: _cargando,
              onPressed: readonly ? null : onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Subwidgets locales ───────────────────────────────────────────────────────

class _SelectorField extends StatelessWidget {
  const _SelectorField({
    required this.label,
    required this.value,
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: enabled ? AppColors.surface : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: enabled ? AppColors.primary : AppColors.textDisabled,
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordatorioToggle extends StatelessWidget {
  const _RecordatorioToggle({
    required this.value,
    required this.enabled,
    this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_outlined,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recordatorio',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Recibirás una notificación al inicio del evento',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryContainer,
          ),
        ],
      ),
    );
  }
}
