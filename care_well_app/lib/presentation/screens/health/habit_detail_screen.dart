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

  final String habitId;

  static String _labelTipo(TipoHabito tipo) {
    switch (tipo) {
      case TipoHabito.actividadFisica:
        return 'Actividad física';
      case TipoHabito.alimentacion:
        return 'Alimentación';
      case TipoHabito.sueno:
        return 'Sueño';
      case TipoHabito.hidratacion:
        return 'Hidratación';
      case TipoHabito.otro:
        return 'Otro';
    }
  }

  static IconData _iconTipo(TipoHabito tipo) {
    switch (tipo) {
      case TipoHabito.actividadFisica:
        return Icons.directions_run;
      case TipoHabito.alimentacion:
        return Icons.restaurant;
      case TipoHabito.sueno:
        return Icons.bedtime_outlined;
      case TipoHabito.hidratacion:
        return Icons.water_drop_outlined;
      case TipoHabito.otro:
        return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitoAsync = ref.watch(habitoByIdProvider(habitId));
    final puede = ref.watch(puedeRegistrarHabitosProvider).valueOrNull ?? false;

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
                pathParameters: {'id': habitId},
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              tooltip: 'Eliminar',
              onPressed: () => ConfirmDialog.show(
                context,
                title: '¿Eliminar este hábito?',
                body:
                    'El registro dejará de mostrarse en la lista. Esta acción no se puede deshacer.',
                confirmLabel: 'Eliminar',
                onConfirm: () async {
                  await ref.read(eliminarHabitoProvider)(habitoId: habitId);
                  if (context.mounted && context.canPop()) context.pop();
                },
              ),
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
                        '${habito.persona.nombre} ${habito.persona.apellido}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
