import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Detalle de un hábito de vida (US-28b).
///
/// Muestra ícono de categoría, descripción y nombre de la persona.
/// Si el usuario tiene permiso, ofrece acciones de editar y eliminar.
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final int habitId;

  static String _labelTipo(TipoHabitoVida tipo) => tipo.descripcion;

  static IconData _iconTipo(TipoHabitoVida tipo) {
    switch (tipo.id) {
      case TiposHabitoConst.actividadFisica:
        return Icons.directions_run;
      case TiposHabitoConst.alimentacion:
        return Icons.restaurant;
      case TiposHabitoConst.sueno:
        return Icons.bedtime_outlined;
      case TiposHabitoConst.hidratacion:
        return Icons.water_drop_outlined;
      default:
        return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitoAsync = ref.watch(habitoByIdProvider(habitId));
    final puede = ref.watch(puedeRegistrarHabitosProvider).valueOrNull ?? false;
    // El registro de cumplimiento diario (marcar realizado / comentar) está
    // disponible para cualquier miembro activo del equipo, sin exigir el
    // permiso de ABM de hábitos.
    final esMiembroEquipo =
        ref.watch(esMiembroEquipoActivoProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: habitoAsync.when(
          data: (h) => Text(
            h != null ? _labelTipo(h.tipo) : 'Hábito',
            overflow: TextOverflow.ellipsis,
          ),
          loading: () => const Text('Cargando...'),
          error: (e, st) => const Text('Hábito'),
        ),
        actions: [
          if (puede) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: () => context.pushNamed(
                AppRoutes.healthHabitEditName,
                pathParameters: {'id': habitId.toString()},
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              tooltip: 'Eliminar',
              onPressed: () async {
                final eliminado = await ConfirmDialog.show(
                  context,
                  title: '¿Eliminar este hábito?',
                  body:
                      'El registro dejará de mostrarse en la lista. Esta acción no se puede deshacer.',
                  confirmLabel: 'Eliminar',
                  onConfirm: () =>
                      ref.read(eliminarHabitoProvider)(habitoId: habitId),
                );
                if (eliminado && context.mounted) context.pop();
              },
            ),
          ],
        ],
      ),
      body: habitoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: InlineErrorBanner(
            message: 'No se pudo cargar el hábito. $err',
          ),
        ),
        data: (habito) {
          if (habito == null) {
            return const Center(child: Text('Hábito no encontrado.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: AppSpacing.elev1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícono de categoría
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.habitsContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _iconTipo(habito.tipo),
                        size: 36,
                        color: AppColors.habitsAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Categoría
                  Center(
                    child: Text(
                      _labelTipo(habito.tipo),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: AppColors.habitsAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Descripción
                  Text(
                    habito.descripcion,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Persona
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        habito.persona.descripcion,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Realización de hoy
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'REALIZACIÓN DE HOY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: esMiembroEquipo
                        ? () => HabitoRealizacionSheet.show(
                            context,
                            ref,
                            habito: habito,
                          )
                        : null,
                    child: _RealizacionDetalleCard(habito: habito),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Tarjeta de realización de hoy ───────────────────────────────────────────

class _RealizacionDetalleCard extends StatelessWidget {
  const _RealizacionDetalleCard({required this.habito});
  final HabitoVida habito;

  @override
  Widget build(BuildContext context) {
    final realizacion = habito.realizacion;
    final realizado = realizacion != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: realizado
            ? AppColors.successContainer
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            realizado
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: 20,
            color: realizado ? AppColors.success : AppColors.textDisabled,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realizado ? 'Realizado' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: realizado
                        ? AppColors.success
                        : AppColors.textDisabled,
                  ),
                ),
                if (realizado) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${realizacion.fechaHora.hour.toString().padLeft(2, '0')}:${realizacion.fechaHora.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (realizacion.comentarios != null &&
                      realizacion.comentarios!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      realizacion.comentarios!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
                if (!realizado)
                  const Text(
                    'Tocá para marcar como realizado.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textDisabled,
                    ),
                  ),
              ],
            ),
          ),
          if (realizado)
            const Icon(
              Icons.edit_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
