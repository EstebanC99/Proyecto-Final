import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-08/10/11 · Pantalla principal de Configuración.
///
/// Agrupa las secciones: Cuenta, Seguridad y privacidad, Legal, Sesión.
/// - US-08: navega a T&C.
/// - US-10: dialog de confirmación para cerrar sesión.
/// - US-11: dialog de confirmación para eliminar cuenta (requiere tipear "DELETE").
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Configuración'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outline),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.sm),

          // Sección Cuenta
          SettingsSection(
            title: 'Cuenta',
            items: [
              SettingsItem(
                icon: Icons.person_outline,
                label: 'Mi Perfil',
                onTap: () => context.pushNamed(AppRoutes.profileName),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sección Seguridad y privacidad
          SettingsSection(
            title: 'Seguridad y privacidad',
            items: [
              SettingsItem(
                icon: Icons.security_outlined,
                label: 'Cambiar contraseña',
                onTap: () =>
                    context.pushNamed(AppRoutes.settingsChangePasswordName),
              ),
              SettingsItem(
                icon: Icons.delete_forever_outlined,
                label: 'Eliminar cuenta',
                destructive: true,
                onTap: () => _mostrarDialogEliminarCuenta(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sección Legal
          SettingsSection(
            title: 'Legal',
            items: [
              SettingsItem(
                icon: Icons.description_outlined,
                label: 'Términos y condiciones',
                onTap: () => context.pushNamed(AppRoutes.settingsTermsName),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sección Sesión
          SettingsSection(
            title: 'Sesión',
            items: [
              SettingsItem(
                icon: Icons.logout,
                label: 'Cerrar sesión',
                destructive: true,
                onTap: () => _mostrarDialogCerrarSesion(context, ref),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  // ── Dialog US-10: Cerrar sesión ───────────────────────────────────────────

  void _mostrarDialogCerrarSesion(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha((0.4 * 255).round()),
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.warning,
          size: 20,
        ),
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
          'Vas a salir de tu cuenta. Podés volver a ingresar cuando quieras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref.read(authStateProvider.notifier).logout();
              // El redirect del router lleva a /login automáticamente.
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  // ── Dialog US-11: Eliminar cuenta ─────────────────────────────────────────

  void _mostrarDialogEliminarCuenta(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha((0.4 * 255).round()),
      builder: (dialogCtx) => _EliminarCuentaDialog(ref: ref),
    );
  }
}

/// Dialog de confirmación de eliminación de cuenta (US-11).
///
/// Requiere que el usuario tipee "DELETE" (case-sensitive, sin espacios
/// adicionales) para habilitar el botón destructivo.
class _EliminarCuentaDialog extends StatefulWidget {
  const _EliminarCuentaDialog({required this.ref});

  final WidgetRef ref;

  @override
  State<_EliminarCuentaDialog> createState() => _EliminarCuentaDialogState();
}

class _EliminarCuentaDialogState extends State<_EliminarCuentaDialog> {
  final _deleteController = TextEditingController();
  bool _isLoading = false;

  bool get _confirmacionCorrecta => _deleteController.text.trim() == 'DELETE';

  @override
  void dispose() {
    _deleteController.dispose();
    super.dispose();
  }

  Future<void> _eliminar() async {
    setState(() => _isLoading = true);
    try {
      await widget.ref.read(authStateProvider.notifier).eliminarCuenta();
      if (mounted) {
        Navigator.of(context).pop();
        // El redirect del router lleva a /login. Mostramos snackbar cuando
        // el contexto del Scaffold padre aún esté disponible.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tu cuenta fue eliminada.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar la cuenta.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.warning,
        size: 24,
      ),
      title: const Text('¿Eliminar tu cuenta?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              children: const [
                TextSpan(text: 'Esta acción es '),
                TextSpan(
                  text: 'irreversible',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '. Se eliminarán todos tus datos, personas a cargo y '
                      'membresías en equipos de cuidado. No podrás recuperar '
                      'tu cuenta.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Escribí DELETE para confirmar:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _deleteController,
            enabled: !_isLoading,
            autocorrect: false,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'DELETE',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.outline),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: _confirmacionCorrecta
                ? AppColors.error
                : AppColors.textDisabled,
          ),
          onPressed: (_confirmacionCorrecta && !_isLoading) ? _eliminar : null,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                )
              : const Text('Eliminar mi cuenta'),
        ),
      ],
    );
  }
}
