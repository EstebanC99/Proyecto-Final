import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../widgets/widgets.dart';

/// Pantalla terminal de confirmación de email verificado (US-01).
///
/// Se accede tras verificar el email con el código OTP: la cuenta ya quedó
/// activa. No inicia sesión automáticamente (el backend no auto-loguea): el
/// back del sistema y el botón principal llevan al login.
class AccountCreatedScreen extends StatelessWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamed(AppRoutes.loginName);
      },
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              children: [
                // Cuerpo central expandido
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icono de exito animado
                      ZoomIn(
                        duration: const Duration(milliseconds: 400),
                        child: Semantics(
                          label: 'Email verificado exitosamente',
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: context.colors.successContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              size: 48,
                              color: context.colors.success,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Titulo
                      Semantics(
                        focusable: true,
                        child: Text(
                          'Email verificado',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: context.colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Subtitulo
                      Text(
                        'Tu cuenta quedó activada. '
                        'Iniciá sesión para empezar a usar CareWell.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Boton inferior
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Ir al login',
                    onPressed: () => context.goNamed(AppRoutes.loginName),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
