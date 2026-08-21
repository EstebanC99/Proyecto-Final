import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/routers/app_navigation.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de confirmación de emergencia enviada (US-34).
///
/// Estado terminal: se accede vía `context.pushReplacementNamed()`, que
/// reemplaza a EmergencyScreen en el tope del stack sin perder las páginas
/// inferiores (Home). El gesto back del sistema navega al inicio y nunca a
/// EmergencyScreen, que ya no está apilada (anti-reenvío).
class EmergencySentScreen extends ConsumerWidget {
  const EmergencySentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipoAsync = ref.watch(equipoEmergenciaProvider);
    final miembros = equipoAsync.value ?? [];
    final ahora = DateFormat('HH:mm:ss').format(DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.volverA(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: context.colors.surface,
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

                      // Título
                      Semantics(
                        focusable: true,
                        child: Text(
                          'Alerta enviada',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Cuerpo: describe la acción ejecutada, no la entrega.
                      // El cliente no puede verificar la recepción del aviso.
                      Text(
                        'Se envió la alerta a tu equipo de cuidado. '
                        'Permanecé donde estás si es seguro hacerlo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Lista del equipo de cuidado (destinatarios del aviso)
                      if (miembros.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Equipo de cuidado',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: context.colors.background,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < miembros.length; i++) ...[
                                EmergencyTeamMemberCard(
                                  asignacion: miembros[i],
                                ),
                                if (i < miembros.length - 1)
                                  Divider(
                                    height: 1,
                                    color: context.colors.surfaceVariant,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),

                      // Timestamp
                      Text(
                        'Alerta enviada a las $ahora',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textDisabled,
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
                      onPressed: () => context.volverA(AppRoutes.home),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: context.colors.primary,
                          width: 2,
                        ),
                        foregroundColor: context.colors.primary,
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
