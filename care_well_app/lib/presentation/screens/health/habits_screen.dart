import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
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
    final puedeRegistrar = puedeRegistrarAsync.value ?? false;
    // El registro de cumplimiento diario (marcar realizado / comentar) está
    // disponible para cualquier miembro activo del equipo, sin exigir el
    // permiso de ABM de hábitos.
    final esMiembroEquipo =
        ref.watch(esMiembroEquipoActivoProvider).value ?? false;
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Hábitos de vida'),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de persona de contexto
          personaAsync.when(
            data: (persona) => persona != null
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: ContextSelector(),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          Expanded(
            child: habitosAsync.when(
              loading: () => _HabitosSkeleton(),
              error: (err, _) => Center(
                child: InlineErrorBanner(
                  message: 'No se pudieron cargar los hábitos. $err',
                ),
              ),
              data: (habitos) {
                if (habitos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.self_improvement,
                            size: 64,
                            color: context.colors.textDisabled,
                          ),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Sin hábitos registrados',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.colors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Empezá a registrar hábitos con el botón +',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.colors.textDisabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: context.colors.habitsAccent,
                  onRefresh: () async {
                    ref.invalidate(habitosProvider);
                    await ref.read(habitosProvider.future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: habitos.length,
                    itemBuilder: (context, i) => _HabitoCard(
                      habito: habitos[i],
                      onTap: () => context.pushNamed(
                        AppRoutes.healthHabitDetailName,
                        pathParameters: {'id': habitos[i].id.toString()},
                      ),
                      onToggleRealizacion: esMiembroEquipo
                          ? () => HabitoRealizacionSheet.show(
                              context,
                              ref,
                              habito: habitos[i],
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: puedeRegistrar
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoutes.healthHabitsNewName),
              tooltip: 'Nuevo hábito',
              backgroundColor: context.colors.habitsAccent,
              child: Icon(Icons.add, color: context.colors.onPrimary),
            )
          : null,
    );
  }
}

// ─── HabitoCard ───────────────────────────────────────────────────────────────

class _HabitoCard extends StatelessWidget {
  const _HabitoCard({
    required this.habito,
    required this.onTap,
    this.onToggleRealizacion,
  });

  final HabitoVida habito;
  final VoidCallback onTap;

  /// Callback para marcar/desmarcar la realización. Null si el usuario no tiene
  /// permiso (el chip se muestra pero no es accionable).
  final VoidCallback? onToggleRealizacion;

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
  Widget build(BuildContext context) {
    final realizado = habito.realizacion != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: AppSpacing.elev1,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.habitsContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconTipo(habito.tipo),
                size: 20,
                color: context.colors.habitsAccent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labelTipo(habito.tipo),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.colors.habitsAccent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habito.descripcion,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: onToggleRealizacion,
              child: _RealizacionChip(realizado: realizado),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chip de estado de realización ───────────────────────────────────────────

class _RealizacionChip extends StatelessWidget {
  const _RealizacionChip({required this.realizado});
  final bool realizado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: realizado
            ? context.colors.successContainer
            : context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            realizado
                ? Icons.check_circle_outline
                : Icons.radio_button_unchecked,
            size: 13,
            color: realizado
                ? context.colors.success
                : context.colors.textDisabled,
          ),
          const SizedBox(width: 4),
          Text(
            realizado ? 'Realizado' : 'Pendiente',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: realizado
                  ? context.colors.success
                  : context.colors.textDisabled,
            ),
          ),
        ],
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
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}
