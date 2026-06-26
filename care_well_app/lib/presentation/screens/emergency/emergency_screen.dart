import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla principal de emergencia (US-34).
///
/// Muestra el [EmergencyButton] pulsante y la lista de miembros que serán notificados.
/// Requiere confirmación via [EmergencyConfirmDialog] antes de activar.
class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipoAsync = ref.watch(equipoEmergenciaProvider);
    final puedeAsync = ref.watch(puedeActivarEmergenciaProvider);
    final personaAsync = ref.watch(careTeamContextPersonaProvider);

    final puede = puedeAsync.valueOrNull ?? false;
    final persona = personaAsync.valueOrNull;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Emergencia',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.emergencyRed,
          ),
        ),
        backgroundColor: AppColors.surface,
        iconTheme: const IconThemeData(color: AppColors.emergencyRed),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outline),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1F0), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Selector de persona de contexto
              if (persona != null) const ContextSelector(),
              const SizedBox(height: AppSpacing.md),

              // Texto explicativo
              const Text(
                'Al activar la emergencia, todos los miembros del equipo '
                'recibirán una notificación inmediata.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Card de miembros a notificar
              equipoAsync.when(
                loading: () => Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                error: (err, _) => InlineErrorBanner(
                  message: 'No se pudo cargar el equipo. $err',
                ),
                data: (miembros) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: AppSpacing.elev1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            size: 20,
                            color: AppColors.emergencyRed,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            miembros.isEmpty
                                ? 'Sin miembros en el equipo'
                                : 'Se notificará a (${miembros.length} personas):',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (miembros.isNotEmpty) ...[
                        const Divider(height: AppSpacing.lg),
                        ...miembros.map(
                          (m) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    '${m.colaborador.nombre} ${m.colaborador.apellido}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  m.rol.id == RolesCuidadoConst.responsable
                                      ? '(Responsable)'
                                      : '(Cuidador/a)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Zona del botón de emergencia
              Tooltip(
                message: puede
                    ? ''
                    : 'No tenés permiso para activar emergencias',
                child: EmergencyButton(
                  enabled:
                      puede && (equipoAsync.valueOrNull?.isNotEmpty ?? false),
                  onTap: () => _handleTap(context, ref),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Tocá el botón para enviar la alerta',
                style: TextStyle(fontSize: 13, color: AppColors.textDisabled),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    final equipo = ref.read(equipoEmergenciaProvider).valueOrNull ?? [];
    final persona = ref.read(careTeamContextPersonaProvider).valueOrNull;
    if (persona == null) return;

    final confirmo = await EmergencyConfirmDialog.show(
      context,
      cantidadMiembros: equipo.length,
      nombrePersona: persona.nombre,
      onConfirm: () async {
        await ref.read(activarEmergenciaProvider)();
      },
    );

    if (confirmo == true && context.mounted) {
      context.goNamed(AppRoutes.emergencySentName);
    }
  }
}
