import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Línea de tiempo de salud de la persona de contexto.
///
/// Muestra, mezclados cronológicamente y filtrados por mes, los hábitos
/// realizados, los eventos de salud y los estados de ánimo registrados. Los
/// ítems son de solo lectura. No tiene gate de permiso explícito: se apoya en
/// el [ContextSelector] y en la persona de visualización seleccionada, igual
/// que el resto del módulo Salud.
class HealthTimelineScreen extends ConsumerWidget {
  const HealthTimelineScreen({super.key});

  /// `true` si [mes] es el mes actual (no hay meses futuros que mostrar).
  bool _esUltimoMes(DateTime mes) {
    final ahora = DateTime.now();
    return mes.year == ahora.year && mes.month == ahora.month;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(lineaTiempoDelMesProvider);
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
    final mes = ref.watch(mesLineaTiempoProvider);

    void irMesAnterior() {
      ref.read(mesLineaTiempoProvider.notifier).state = DateTime(
        mes.year,
        mes.month - 1,
        1,
      );
    }

    void irMesSiguiente() {
      ref.read(mesLineaTiempoProvider.notifier).state = DateTime(
        mes.year,
        mes.month + 1,
        1,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Línea de tiempo'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
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

          // Navegación mensual — no se permite avanzar a meses futuros.
          MonthNavHeader(
            mes: mes,
            onPrevious: irMesAnterior,
            onNext: _esUltimoMes(mes) ? null : irMesSiguiente,
          ),

          Expanded(
            child: eventosAsync.when(
              loading: () => const _TimelineSkeleton(),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: InlineErrorBanner(
                    message: 'No se pudo cargar la línea de tiempo. $err',
                  ),
                ),
              ),
              data: (eventos) {
                if (personaAsync.value == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Primero agregá una persona a cargo para ver su línea de tiempo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                }

                if (eventos.isEmpty) {
                  return const _EmptyMonthState();
                }

                Future<void> onRefresh() async {
                  ref.invalidate(lineaTiempoDelMesProvider);
                  await ref.read(lineaTiempoDelMesProvider.future);
                }

                return HealthTimelineView(
                  eventos: eventos,
                  onRefresh: onRefresh,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Estado vacío del mes ─────────────────────────────────────────────────────

class _EmptyMonthState extends StatelessWidget {
  const _EmptyMonthState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline, size: 64, color: AppColors.textDisabled),
            SizedBox(height: AppSpacing.md),
            Text(
              'Sin registros en este mes.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton de carga ────────────────────────────────────────────────────────

class _TimelineSkeleton extends StatelessWidget {
  const _TimelineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            width: 120,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          ...List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
