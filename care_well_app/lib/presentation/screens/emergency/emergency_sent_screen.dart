import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de confirmación de emergencia enviada (US-34).
///
/// Estado terminal: se accede via `context.go()`, no `push()`.
/// El gesto back del sistema navega al inicio, no a EmergencyScreen (anti-reenvío).
class EmergencySentScreen extends ConsumerWidget {
  const EmergencySentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipoAsync = ref.watch(equipoEmergenciaProvider);
    final miembros = equipoAsync.valueOrNull ?? [];
    final ahora = DateFormat('HH:mm:ss').format(DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamed(AppRoutes.homeName);
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
                          label: 'Alerta enviada exitosamente',
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
                          'Alerta enviada',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Cuerpo
                      Text(
                        '${miembros.length} persona${miembros.length != 1 ? 's fueron' : ' fue'} notificada${miembros.length != 1 ? 's' : ''}. '
                        'Permanecé donde estás si es seguro hacerlo.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Card de miembros notificados
                      if (miembros.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < miembros.length; i++) ...[
                                NotifiedMembersCard(asignacion: miembros[i]),
                                if (i < miembros.length - 1)
                                  const Divider(
                                    height: 1,
                                    color: AppColors.surfaceVariant,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),

                      // Timestamp
                      Text(
                        'Alerta enviada a las $ahora',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón volver al inicio
                const SizedBox(height: AppSpacing.xl),
                Semantics(
                  label: 'Volver al menú principal',
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.goNamed(AppRoutes.homeName),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Volver al inicio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
