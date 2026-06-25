import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de lista de hábitos de vida (US-28).
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitosAsync = ref.watch(habitosProvider);
    final puedeRegistrarAsync = ref.watch(puedeRegistrarHabitosProvider);
    final puedeRegistrar = puedeRegistrarAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hábitos de vida'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: habitosAsync.when(
        loading: () => _HabitosSkeleton(),
        error: (err, _) => Center(
          child: InlineErrorBanner(
            message: 'No se pudieron cargar los hábitos. $err',
          ),
        ),
        data: (habitos) {
          if (habitos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.self_improvement,
                      size: 64,
                      color: AppColors.textDisabled,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Sin hábitos registrados',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Empezá a registrar hábitos con el botón +',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: habitos.length,
            itemBuilder: (context, i) => _HabitoCard(
              habito: habitos[i],
              onTap: () => context.pushNamed(
                AppRoutes.healthHabitDetailName,
                pathParameters: {'id': habitos[i].id.toString()},
              ),
            ),
          );
        },
      ),
      floatingActionButton: puedeRegistrar
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoutes.healthHabitsNewName),
              tooltip: 'Nuevo hábito',
              backgroundColor: AppColors.habitsAccent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

// ─── HabitoCard ───────────────────────────────────────────────────────────────

class _HabitoCard extends StatelessWidget {
  const _HabitoCard({required this.habito, required this.onTap});

  final HabitoDeVida habito;
  final VoidCallback onTap;

  static String _labelTipo(TipoHabito tipo) => tipo.descripcion;

  static IconData _iconTipo(TipoHabito tipo) {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: AppSpacing.elev1,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.habitsContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconTipo(habito.tipo),
                size: 20,
                color: AppColors.habitsAccent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelTipo(habito.tipo),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.habitsAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habito.descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _HabitosSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: List.generate(
          4,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}
