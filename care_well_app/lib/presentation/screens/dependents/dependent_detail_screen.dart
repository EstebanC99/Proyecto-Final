import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-14/15 · Detalle y edición de persona a cargo.
///
/// Pantalla con estado mutable para todos los campos editables. El usuario
/// toca directamente el valor de cada campo para editarlo. Un único botón
/// "Guardar cambios" al final realiza un solo request al backend con todos
/// los cambios juntos. La fecha de nacimiento abre un [DatePicker] al tocar.
class DependentDetailScreen extends ConsumerStatefulWidget {
  const DependentDetailScreen({super.key, required this.asignacionId});

  final int asignacionId;

  @override
  ConsumerState<DependentDetailScreen> createState() =>
      _DependentDetailScreenState();
}

class _DependentDetailScreenState extends ConsumerState<DependentDetailScreen> {
  // ── Controllers de texto ───────────────────────────────────────────────────
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _documentoController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();

  // ── Errores de validación inline ───────────────────────────────────────────
  String? _nombreError;
  String? _apellidoError;
  String? _documentoError;
  String? _emailError;

  // ── Campo especial: fecha ──────────────────────────────────────────────────
  DateTime? _fechaNacimiento;

  // ── Referencia al estado original (para detectar cambios) ─────────────────
  Persona? _personaOriginal;

  bool _isLoading = false;

  // ── Inicialización ─────────────────────────────────────────────────────────

  void _inicializarDesdePersona(Persona persona) {
    _personaOriginal = persona;
    _nombreController.text = persona.nombre;
    _apellidoController.text = persona.apellido;
    _documentoController.text = persona.documento;
    _fechaNacimiento = persona.fechaNacimiento;
    _emailController.text = persona.email ?? '';
    _telefonoController.text = persona.telefono ?? '';
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _documentoController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // ── Detección de cambios ───────────────────────────────────────────────────

  bool get _hayCambios {
    final original = _personaOriginal;
    if (original == null) return false;
    return _nombreController.text.trim() != original.nombre ||
        _apellidoController.text.trim() != original.apellido ||
        _documentoController.text.trim() != (original.documento) ||
        _emailController.text.trim() != (original.email ?? '') ||
        _telefonoController.text.trim() != (original.telefono ?? '') ||
        _fechaNacimiento != original.fechaNacimiento;
  }

  // ── Validación ─────────────────────────────────────────────────────────────

  bool _validar() {
    final nombreErr = validateNombre(_nombreController.text);
    final apellidoErr = validateApellido(_apellidoController.text);
    final documentoErr = validateDocumento(_documentoController.text);
    String? emailErr;
    if (_emailController.text.trim().isNotEmpty) {
      emailErr = validateEmail(_emailController.text.trim());
    }

    setState(() {
      _nombreError = nombreErr;
      _apellidoError = apellidoErr;
      _documentoError = documentoErr;
      _emailError = emailErr;
    });

    if (_fechaNacimiento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccioná la fecha de nacimiento.'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }

    return nombreErr == null &&
        apellidoErr == null &&
        documentoErr == null &&
        emailErr == null;
  }

  // ── Guardar ────────────────────────────────────────────────────────────────

  Future<void> _guardar() async {
    if (!_validar()) return;
    setState(() => _isLoading = true);

    try {
      final personaActualizada = _personaOriginal!.copyWith(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        documento: _documentoController.text.trim().replaceAll(
          RegExp(r'\D'),
          '',
        ),
        fechaNacimiento: _fechaNacimiento,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        telefono: _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim(),
      );

      final actualizar = ref.read(actualizarDependenteProvider);
      final resultado = await actualizar(
        widget.asignacionId,
        personaActualizada,
      );

      if (!mounted) return;

      // Actualizar referencia original para resetear _hayCambios
      setState(() {
        _personaOriginal = resultado;
        // Re-sincronizar campos que pueden haber sido normalizados
        _documentoController.text = resultado.documento;
        _emailController.text = resultado.email ?? '';
        _telefonoController.text = resultado.telefono ?? '';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${resultado.nombreCompleto} fue actualizado.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al guardar: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── DatePicker ─────────────────────────────────────────────────────────────

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final initial =
        _fechaNacimiento ?? DateTime(hoy.year - 30, hoy.month, hoy.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: hoy,
    );
    if (picked != null) {
      setState(() => _fechaNacimiento = picked);
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  void _mostrarProximamente() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad disponible próximamente.')),
    );
  }

  Future<void> _confirmarEliminar(AsignacionCuidado asignacion) async {
    var nombreCompletoPersona = asignacion.personaCuidada.nombreCompleto;

    final confirmo = await ConfirmDialog.show(
      context,
      title: '¿Eliminar a $nombreCompletoPersona?',
      body:
          '$nombreCompletoPersona será eliminado de tu lista de personas a cargo.'
          'Esta acción no se puede deshacer pasado los 30 días.',
      confirmLabel: 'Eliminar',
      icon: Icons.delete_outline,
      onConfirm: () async {
        final eliminar = ref.read(eliminarDependenteProvider);

        await eliminar(asignacion.id);
      },
    );
    if (confirmo && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$nombreCompletoPersona fue eliminado.'),
          backgroundColor: AppColors.success,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(AppRoutes.dependentsName);
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final asignacionAsync = ref.watch(
      asignacionByIdProvider(widget.asignacionId),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Persona a cargo'),
        actions: [
          asignacionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (asignacion) {
              final esPendiente =
                  asignacion.estado.id == EstadosAsignacionConst.pendiente;

              if (esPendiente) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      icon: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 20,
                      ),
                      label: const Text(
                        'Aceptar',
                        style: TextStyle(color: AppColors.success),
                      ),
                      onPressed: _mostrarProximamente,
                    ),
                    TextButton.icon(
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.error,
                        size: 20,
                      ),
                      label: const Text(
                        'Rechazar',
                        style: TextStyle(color: AppColors.error),
                      ),
                      onPressed: _mostrarProximamente,
                    ),
                  ],
                );
              }

              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) async {
                  if (value == 'eliminar') {
                    await _confirmarEliminar(asignacion);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Eliminar asignación',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: asignacionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: InlineErrorBanner(
            message:
                'No se pudo cargar la persona. '
                '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
        data: (asignacion) {
          final persona = asignacion.personaCuidada;

          // Inicializar controllers la primera vez o si cambia la persona.
          if (_personaOriginal == null || _personaOriginal!.id != persona.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _inicializarDesdePersona(persona));
            });
          }

          return _buildBody(persona);
        },
      ),
    );
  }

  Widget _buildBody(Persona persona) {
    final fechaCambiada = _fechaNacimiento != _personaOriginal?.fechaNacimiento;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      AvatarInitial(nombre: persona.nombre, size: 80),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        persona.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...[
                        Text(
                          () {
                            final edad = calcularEdad(persona.fechaNacimiento);
                            return edad != null ? '$edad años' : '';
                          }(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      const RoleBadge(rol: 'Persona a cargo'),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.outline,
                ),

                // ── Campos editables ──────────────────────────────────────
                _EditableField(
                  icon: Icons.person_outline,
                  label: 'Nombre',
                  controller: _nombreController,
                  errorText: _nombreError,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _nombreError = null),
                ),
                _EditableField(
                  icon: Icons.person_outline,
                  label: 'Apellido',
                  controller: _apellidoController,
                  errorText: _apellidoError,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _apellidoError = null),
                ),
                _EditableField(
                  icon: Icons.badge_outlined,
                  label: 'DNI',
                  controller: _documentoController,
                  errorText: _documentoError,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _documentoError = null),
                ),
                _FechaField(
                  fecha: _fechaNacimiento,
                  formatFecha: _formatFecha,
                  cambiada: fechaCambiada,
                  onTap: _seleccionarFecha,
                ),
                _EditableField(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  controller: _emailController,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() => _emailError = null),
                ),
                _EditableField(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                ),

                // Espacio para que el botón no tape el último campo
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),

        // ── Botón Guardar (solo si hay cambios) ───────────────────────────
        if (_hayCambios)
          _SaveBar(
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _guardar,
          ),
      ],
    );
  }
}

// ─── _EditableField ───────────────────────────────────────────────────────────

/// Fila de perfil con campo de texto editable.
///
/// Estilo: sin borde exterior, fondo blanco, separador inferior. Ícono a la
/// izquierda, label pequeño arriba, [TextField] sin borde en reposo y con
/// subrayado primario al tener foco. El usuario toca el valor para editarlo.
class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.icon,
    required this.label,
    required this.controller,
    this.errorText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.autocorrect = true,
    this.onChanged,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool autocorrect;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Icon(icon, size: 20, color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      textCapitalization: textCapitalization,
                      textInputAction: textInputAction,
                      autocorrect: autocorrect,
                      onChanged: onChanged,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        errorText: errorText,
                        errorStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.outline),
      ],
    );
  }
}

// ─── _FechaField ──────────────────────────────────────────────────────────────

/// Fila de perfil para la fecha de nacimiento.
///
/// Al tocar la fila se abre el [DatePicker]. Mientras la fecha seleccionada
/// difiere de la original, el valor se muestra en [AppColors.primary] como
/// indicador visual de cambio pendiente de guardar.
class _FechaField extends StatelessWidget {
  const _FechaField({
    required this.fecha,
    required this.formatFecha,
    required this.cambiada,
    required this.onTap,
  });

  final DateTime? fecha;
  final String Function(DateTime?) formatFecha;

  /// `true` si la fecha difiere del valor original (cambio pendiente de guardar).
  final bool cambiada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final valorTexto = fecha != null ? formatFecha(fecha) : '—';
    final colorValor = cambiada ? AppColors.primary : AppColors.textPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            color: AppColors.surface,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Fecha de nacimiento',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        valorTexto,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: colorValor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.edit_calendar_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.outline),
      ],
    );
  }
}

// ─── _SaveBar ─────────────────────────────────────────────────────────────────

/// Barra fija al fondo con el botón "Guardar cambios".
///
/// Solo se renderiza cuando hay cambios pendientes ([_hayCambios] en el estado
/// padre). Muestra un spinner durante el guardado.
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: FilledButton(
            onPressed: onPressed,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.onPrimary,
                    ),
                  )
                : const Text(
                    'Guardar cambios',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ),
    );
  }
}
