import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de confirmación de ficha de salud guardada (US-35).
///
/// Estado terminal: se accede vía `context.pushReplacementNamed()`, que
/// reemplaza el formulario por esta pantalla en el tope del stack sin perder
/// las páginas inferiores (Home, hub de Salud). El botón "Aceptar" y el gesto
/// back reemplazan esta pantalla por un formulario fresco, que se reconstruye
/// y refetchea la ficha persistida, preservando el resto del stack.
class FichaSaludSuccessScreen extends ConsumerWidget {
  const FichaSaludSuccessScreen({super.key});

  /// Invalida la ficha (para releer los ids reales) y vuelve al formulario.
  void _salir(BuildContext context, WidgetRef ref) {
    ref.invalidate(fichaSaludProvider);
    context.pushReplacementNamed(AppRoutes.healthRecordName);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _salir(context, ref);
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              children: [
                // Cuerpo central
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícono de éxito animado
                      ZoomIn(
                        duration: const Duration(milliseconds: 400),
                        child: Semantics(
                          label: 'Ficha de salud guardada',
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

                      // Título
                      Semantics(
                        focusable: true,
                        child: const Text(
                          'Ficha de salud guardada',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Cuerpo
                      const Text(
                        'Los datos de salud se guardaron correctamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón inferior
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    label: 'Aceptar',
                    onPressed: () => _salir(context, ref),
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
