import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-08/10/11 · Pantalla principal de Configuración.
///
/// Agrupa las secciones: Seguridad y privacidad, Legal y Zona sensible, con la
/// identidad del usuario arriba (acceso a "Mi Perfil") y el cierre de sesión
/// como acción secundaria al pie.
/// - US-06: la tarjeta de usuario navega al perfil.
/// - US-08: navega a T&C y a la política de privacidad.
/// - US-10: dialog de confirmación para cerrar sesión.
/// - US-11: dialog de confirmación para eliminar cuenta (requiere tipear "DELETE").
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sinAnimacion = MediaQuery.disableAnimationsOf(context);

    Widget anim(Widget child, int delayMs) => sinAnimacion
        ? child
        : FadeInUp(
            delay: Duration(milliseconds: delayMs),
            child: child,
          );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        elevation: 0,
        // El título va en la barra y con la tipografía del tema, como el resto
        // de la app: un título grande propio en el cuerpo hacía que esta
        // pantalla se leyera distinta de todas las demás.
        title: const Text('Configuración'),
      ),
      body: ListView(
        // El `top` reemplaza el aire que aportaba el título del cuerpo: sin él
        // la tarjeta de usuario queda pegada al AppBar. El bottom es 0 porque
        // el `SizedBox` del final ya deja el colchón de scroll.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          0,
        ),
        children: [
          anim(const _TarjetaUsuario(), 0),

          // Sección Seguridad y privacidad
          anim(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel(text: 'Seguridad y privacidad'),
                CardGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.lock_outline,
                      label: 'Cambiar contraseña',
                      subtitle: 'Se te pedirá tu contraseña actual',
                      onTap: () => context.pushNamed(
                        AppRoutes.settingsChangePasswordName,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            50,
          ),

          // Sección Legal
          anim(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel(text: 'Legal'),
                CardGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.description_outlined,
                      label: 'Términos y condiciones',
                      iconColor: context.colors.info,
                      iconBackground: context.colors.infoContainer,
                      onTap: () =>
                          context.pushNamed(AppRoutes.settingsTermsName),
                    ),
                    SettingsItem(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Política de privacidad',
                      iconColor: context.colors.info,
                      iconBackground: context.colors.infoContainer,
                      onTap: () =>
                          context.pushNamed(AppRoutes.settingsPrivacyName),
                    ),
                    SettingsItem(
                      icon: Icons.info_outline,
                      label: 'Acerca de CareWell',
                      iconColor: context.colors.info,
                      iconBackground: context.colors.infoContainer,
                      onTap: () async {
                        // Sin manejo de error: la lectura del paquete instalado
                        // no falla en Android; de fallar, el efecto es que el
                        // diálogo no se abre.
                        final version = await ref.read(
                          appVersionProvider.future,
                        );
                        if (!context.mounted) return;
                        await mostrarAcercaDeCareWell(
                          context,
                          version: version,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            100,
          ),

          // Sección Zona sensible
          anim(
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionLabel(text: 'Zona sensible'),
                CardGroup(
                  children: [
                    SettingsItem(
                      icon: Icons.delete_forever_outlined,
                      label: 'Eliminar cuenta',
                      destructive: true,
                      showChevron: false,
                      subtitle:
                          'Perderás el acceso y tus datos dejarán de estar '
                          'disponibles. No se puede deshacer.',
                      subtitleMaxLines: 3,
                      onTap: () => _mostrarDialogEliminarCuenta(context, ref),
                    ),
                  ],
                ),
              ],
            ),
            150,
          ),

          // Cerrar sesión: acción secundaria, no destructiva. Gris deliberado
          // (la cuenta no se pierde), fuera de las tarjetas para separarla de
          // los ítems de navegación.
          anim(
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _mostrarDialogCerrarSesion(context, ref),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: context.colors.surface,
                    foregroundColor: context.colors.textSecondary,
                    side: BorderSide(color: context.colors.outline, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ),
            ),
            200,
          ),

          const _PieDeVersion(),
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
      barrierColor: context.colors.scrim,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        icon: Icon(
          Icons.warning_amber_rounded,
          color: context.colors.warning,
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
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              // Da de baja el dispositivo push antes de limpiar la sesión.
              await ref.read(cerrarSesionProvider)();
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
      barrierColor: context.colors.scrim,
      builder: (dialogCtx) => _EliminarCuentaDialog(ref: ref),
    );
  }
}

/// Tarjeta de identidad del usuario autenticado, con acceso al perfil.
///
/// Observa `authStateProvider` sólo acá y no envolviendo la pantalla: si la
/// sesión no resuelve, Configuración tiene que seguir siendo usable (el usuario
/// necesita poder llegar a "Cerrar sesión"). Por eso el estado de error —y el
/// de usuario nulo— degradan a nada en lugar de bloquear la vista con un
/// banner.
class _TarjetaUsuario extends ConsumerWidget {
  const _TarjetaUsuario();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(authStateProvider)
        .when(
          loading: () => const SettingsUserCardSkeleton(),
          error: (_, _) => const SizedBox.shrink(),
          data: (usuario) => usuario == null
              ? const SizedBox.shrink()
              : SettingsUserCard(
                  persona: usuario.persona,
                  onTap: () => context.pushNamed(AppRoutes.profileName),
                ),
        );
  }
}

/// Pie con la versión instalada de la app.
///
/// Lee el `AsyncValue` por su getter nullable `value` a propósito (en Riverpod
/// 3 es el equivalente al `valueOrNull` de 2.x): mientras carga —o si la
/// lectura del paquete falla— muestra el texto sin versión, en lugar de dejar
/// el pie vacío o desplazar el layout cuando el valor llega.
class _PieDeVersion extends ConsumerWidget {
  const _PieDeVersion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).value;
    final texto = version == null
        ? 'CareWell · Bubisoft'
        : 'CareWell v$version · Bubisoft';

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11.5, color: context.colors.textDisabled),
      ),
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
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
      icon: Icon(
        Icons.warning_amber_rounded,
        color: context.colors.warning,
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
                color: context.colors.textSecondary,
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
              color: context.colors.textSecondary,
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
                borderSide: BorderSide(color: context.colors.outline),
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
                ? context.colors.error
                : context.colors.textDisabled,
          ),
          onPressed: (_confirmacionCorrecta && !_isLoading) ? _eliminar : null,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: context.colors.error,
                  ),
                )
              : const Text('Eliminar mi cuenta'),
        ),
      ],
    );
  }
}
