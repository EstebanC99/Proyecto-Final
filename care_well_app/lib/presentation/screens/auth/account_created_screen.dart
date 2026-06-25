import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../widgets/widgets.dart';

/// Pantalla terminal de confirmación de cuenta creada (US-01).
///
/// Se accede tras un registro exitoso. El back del sistema no vuelve
/// al formulario: redirige al login.
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
        backgroundColor: AppColors.background,
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
                          label: 'Cuenta creada exitosamente',
                          child: Container(
                            width: 88,
                            height: 88,
                            decoration: const BoxDecoration(
                              color: AppColors.successContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              size: 48,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Titulo
                      Semantics(
                        focusable: true,
                        child: Text(
                          'Cuenta creada',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Subtitulo
                      Text(
                        'Tu cuenta se creó correctamente. '
                        'Iniciá sesión para empezar a usar CareWell.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
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
