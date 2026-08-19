import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
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
    final gruposAsync = ref.watch(lineaTiempoAgrupadaProvider);
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
    final mes = ref.watch(mesLineaTiempoProvider);
    final filtro = ref.watch(filtroCategoriaTimelineProvider);

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
      backgroundColor: context.colors.background,
      appBar: const ContextAppBar(eyebrow: 'Línea de tiempo'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Navegación mensual — no se permite avanzar a meses futuros.
          MonthNavHeader(
            mes: mes,
            onPrevious: irMesAnterior,
            onNext: _esUltimoMes(mes) ? null : irMesSiguiente,
          ),

          // Filtrado en cliente sobre los registros del mes ya cargados.
          TimelineCategoryFilter(
            seleccionada: filtro,
            onChanged: (categoria) =>
                ref.read(filtroCategoriaTimelineProvider.notifier).state =
                    categoria,
          ),

          Expanded(
            child: gruposAsync.when(
              loading: () => const _TimelineSkeleton(),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: InlineErrorBanner(
                    message: 'No se pudo cargar la línea de tiempo. $err',
                  ),
                ),
              ),
              data: (grupos) {
                if (personaAsync.value == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Primero agregá una persona a cargo para ver su línea de tiempo.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: context.colors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                }

                if (grupos.isEmpty) {
                  return _EmptyMonthState(filtro: filtro);
                }

                Future<void> onRefresh() async {
                  ref.invalidate(lineaTiempoDelMesProvider);
                  await ref.read(lineaTiempoDelMesProvider.future);
                }

                return HealthTimelineView(grupos: grupos, onRefresh: onRefresh);
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
  const _EmptyMonthState({this.filtro});

  /// Categoría activa. Con una puesta, el vacío es del filtro y no del mes: si
  /// dijera "sin registros en este mes" el usuario podría creer que no cargó
  /// nada, cuando en realidad hay registros de otras categorías.
  final String? filtro;

  @override
  Widget build(BuildContext context) {
    final categoria = filtro;
    final mensaje = categoria == null
        ? 'Sin registros en este mes.'
        : 'Sin registros de '
              '${categoriaEventoLabel(categoria).toLowerCase()} '
              'en este mes.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline, size: 64, color: context.colors.textDisabled),
            const SizedBox(height: AppSpacing.md),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.textSecondary,
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
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          ...List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              height: 80,
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
