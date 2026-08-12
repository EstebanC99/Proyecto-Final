import 'dart:math' as math;

import 'package:animate_do/animate_do.dart';
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
///
/// Bajo el AppBar hay una banda fija con el progreso del día; el listado agrupa
/// los hábitos en pendientes y completados, sin reordenar dentro de cada grupo.
class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  /// Cantidad de items que reciben delay escalonado en la animación de entrada.
  /// Más allá de eso la cascada se percibe como lentitud.
  static const int _maxItemsAnimados = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitosAsync = ref.watch(habitosProvider);
    final progresoAsync = ref.watch(progresoHabitosHoyProvider);
    final puedeRegistrarAsync = ref.watch(puedeRegistrarHabitosProvider);
    final puedeRegistrar = puedeRegistrarAsync.value ?? false;
    // El registro de cumplimiento diario (marcar realizado / comentar) está
    // disponible para cualquier miembro activo del equipo, sin exigir el
    // permiso de ABM de hábitos.
    final esMiembroEquipo =
        ref.watch(esMiembroEquipoActivoProvider).value ?? false;

    final progreso = switch (progresoAsync) {
      AsyncData(:final value) when value.total > 0 => value,
      _ => null,
    };

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const ContextAppBar(eyebrow: 'Hábitos de vida'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (habitosAsync.isLoading)
            const _ProgressHeaderSkeleton()
          else if (progreso != null)
            HabitsDayProgressHeader(
              completados: progreso.completados,
              total: progreso.total,
            ),
          Expanded(
            child: habitosAsync.when(
              loading: () => const _HabitosSkeleton(),
              error: (err, _) => Center(
                child: InlineErrorBanner(
                  message: 'No se pudieron cargar los hábitos. $err',
                ),
              ),
              data: (habitos) {
                if (habitos.isEmpty) {
                  return _EmptyState(puedeRegistrar: puedeRegistrar);
                }
                return RefreshIndicator(
                  color: context.colors.habitsAccent,
                  onRefresh: () async {
                    ref.invalidate(habitosProvider);
                    await ref.read(habitosProvider.future);
                  },
                  child: _HabitosList(
                    habitos: habitos,
                    esMiembroEquipo: esMiembroEquipo,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Icon(Icons.add, color: context.colors.onPrimary),
            )
          : null,
    );
  }
}

// ─── Listado agrupado ─────────────────────────────────────────────────────────

/// Listado de hábitos agrupado en pendientes y completados.
///
/// El orden dentro de cada grupo es el que devuelve el provider: marcar un
/// hábito lo mueve de sección, pero no reordena a sus compañeros.
class _HabitosList extends ConsumerWidget {
  const _HabitosList({required this.habitos, required this.esMiembroEquipo});

  final List<HabitoVida> habitos;
  final bool esMiembroEquipo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientes = habitos.where((h) => h.realizacion == null).toList();
    final completados = habitos.where((h) => h.realizacion != null).toList();

    // Contador global de items para escalonar la animación de entrada a lo
    // largo de las dos secciones.
    var indice = 0;
    Widget card(HabitoVida habito) => _buildCard(
      context,
      ref,
      habito,
      math.min(indice++, HabitsScreen._maxItemsAnimados),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      children: [
        if (pendientes.isNotEmpty) ...[
          SectionLabel(text: 'Pendientes', count: pendientes.length),
          for (final habito in pendientes) card(habito),
        ],
        if (completados.isNotEmpty) ...[
          SectionLabel(text: 'Completados', count: completados.length),
          for (final habito in completados) card(habito),
        ],
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref,
    HabitoVida habito,
    int posicionAnimada,
  ) {
    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      delay: Duration(milliseconds: 50 * posicionAnimada),
      child: HabitoCard(
        habito: habito,
        onTap: () => context.pushNamed(
          AppRoutes.healthHabitDetailName,
          pathParameters: {'id': habito.id.toString()},
        ),
        onToggleRealizacion: esMiembroEquipo
            ? () => HabitoRealizacionSheet.show(context, ref, habito: habito)
            : null,
      ),
    );
  }
}

// ─── Estado vacío ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.puedeRegistrar});

  final bool puedeRegistrar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.self_improvement,
              size: 64,
              color: context.colors.habitsAccent.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin hábitos registrados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.textSecondary,
              ),
            ),
            // La ayuda menciona el botón +, que sólo existe con permiso de ABM.
            if (puedeRegistrar) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Empezá a registrar hábitos con el botón +',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textDisabled,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Skeletons ────────────────────────────────────────────────────────────────

/// Placeholder de la banda de progreso mientras cargan los hábitos.
class _ProgressHeaderSkeleton extends StatelessWidget {
  const _ProgressHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.colors.outline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 22,
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitosSkeleton extends StatelessWidget {
  const _HabitosSkeleton();

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
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}
