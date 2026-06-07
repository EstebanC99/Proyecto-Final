import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-09 · Cambio de contraseña para el usuario autenticado.
///
/// La sesión se mantiene activa tras el cambio exitoso.
/// Al confirmar el éxito muestra un estado visual de confirmación con CTA
/// para volver a Configuración.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _actualController = TextEditingController();
  final _nuevaController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _mostrarActual = false;
  bool _mostrarNueva = false;

  bool _isLoading = false;
  bool _exitoso = false;
  String? _errorActual;

  @override
  void dispose() {
    _actualController.dispose();
    _nuevaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() => _errorActual = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .cambiarContrasena(
            contrasenaActual: _actualController.text,
            nuevaContrasena: _nuevaController.text,
          );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _exitoso = true;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        final mensaje = e.toString().replaceFirst('Exception: ', '');
        // Si el datasource lanza "incorrecta", lo mostramos en el campo actual.
        if (mensaje.toLowerCase().contains('incorrecta') ||
            mensaje.toLowerCase().contains('actual')) {
          setState(() {
            _isLoading = false;
            _errorActual = 'Contraseña incorrecta';
          });
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(mensaje)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_exitoso) return _buildExito(context);
    return _buildFormulario(context);
  }

  // ── Estado formulario ────────────────────────────────────────────────────────

  Widget _buildFormulario(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Cambiar contraseña'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outline),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nueva contraseña',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Tu nueva contraseña reemplazará la actual.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Campo contraseña actual
                AppTextField(
                  label: 'Contraseña actual',
                  controller: _actualController,
                  obscureText: !_mostrarActual,
                  enabled: !_isLoading,
                  errorText: _errorActual,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _mostrarActual
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _mostrarActual = !_mostrarActual),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  autocorrect: false,
                  onChanged: (_) {
                    if (_errorActual != null) {
                      setState(() => _errorActual = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Campo nueva contraseña
                _NuevaContrasenaField(
                  controller: _nuevaController,
                  mostrar: _mostrarNueva,
                  enabled: !_isLoading,
                  onToggleVisibility: () =>
                      setState(() => _mostrarNueva = !_mostrarNueva),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Campo confirmar nueva contraseña
                _ConfirmarContrasenaField(
                  controller: _confirmarController,
                  nuevaController: _nuevaController,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Guardar cambios',
                    onPressed: _isLoading ? null : _guardar,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Estado éxito ─────────────────────────────────────────────────────────────

  Widget _buildExito(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Círculo con ícono check
              Container(
                width: 112,
                height: 112,
                decoration: const BoxDecoration(
                  color: AppColors.successContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Título
              Text(
                'Contraseña actualizada',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtítulo
              Text(
                'Tu nueva contraseña ya está activa.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // CTA
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Volver a Configuración',
                  onPressed: () => context.go(AppRoutes.settings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _NuevaContrasenaField extends StatefulWidget {
  const _NuevaContrasenaField({
    required this.controller,
    required this.mostrar,
    required this.enabled,
    required this.onToggleVisibility,
  });

  final TextEditingController controller;
  final bool mostrar;
  final bool enabled;
  final VoidCallback onToggleVisibility;

  @override
  State<_NuevaContrasenaField> createState() => _NuevaContrasenaFieldState();
}

class _NuevaContrasenaFieldState extends State<_NuevaContrasenaField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Nueva contraseña',
          controller: widget.controller,
          obscureText: !widget.mostrar,
          enabled: widget.enabled,
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              widget.mostrar
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
            ),
            onPressed: widget.onToggleVisibility,
          ),
          keyboardType: TextInputType.visiblePassword,
          autocorrect: false,
          onChanged: (_) => setState(() {}),
        ),
        if (widget.controller.text.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          PasswordStrengthMeter(password: widget.controller.text),
        ],
      ],
    );
  }
}

class _ConfirmarContrasenaField extends StatelessWidget {
  const _ConfirmarContrasenaField({
    required this.controller,
    required this.nuevaController,
    required this.enabled,
  });

  final TextEditingController controller;
  final TextEditingController nuevaController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (_) =>
          validatePasswordMatch(controller.text, nuevaController.text),
      builder: (field) {
        return AppTextField(
          label: 'Confirmar nueva contraseña',
          controller: controller,
          obscureText: true,
          enabled: enabled,
          prefixIcon: const Icon(Icons.lock_outline, size: 20),
          errorText: field.errorText,
          keyboardType: TextInputType.visiblePassword,
          autocorrect: false,
        );
      },
    );
  }
}
