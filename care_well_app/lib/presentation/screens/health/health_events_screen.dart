import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Lista mensual de eventos de salud agrupada por día (US-30).
///
/// Muestra los eventos del mes seleccionado para la persona de contexto,
/// agrupados por día en orden ascendente. Permite navegar entre meses y —para
/// usuarios con permiso [PermisosCuidadoConst.registrarEventosSalud]—
/// registrar nuevos eventos mediante el FAB.
class HealthEventsScreen extends ConsumerWidget {
  const HealthEventsScreen({super.key});

  /// `true` si [mes] es el mes actual (no hay meses futuros que mostrar).
  bool _esUltimoMes(DateTime mes) {
    final ahora = DateTime.now();
    return mes.year == ahora.year && mes.month == ahora.month;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(eventosSaludDelMesProvider);
    final puede = ref.watch(puedeRegistrarEventosSaludProvider).value ?? false;
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
    final mes = ref.watch(mesEventosSaludProvider);

    void irMesAnterior() {
      ref.read(mesEventosSaludProvider.notifier).state = DateTime(
        mes.year,
        mes.month - 1,
        1,
      );
    }

    void irMesSiguiente() {
      ref.read(mesEventosSaludProvider.notifier).state = DateTime(
        mes.year,
        mes.month + 1,
        1,
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Eventos de salud'),
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

          // Navegación mensual — no se permite avanzar a meses futuros.
          MonthNavHeader(
            mes: mes,
            onPrevious: irMesAnterior,
            onNext: _esUltimoMes(mes) ? null : irMesSiguiente,
          ),

          Expanded(
            child: eventosAsync.when(
              loading: () => const _EventosSkeleton(),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: InlineErrorBanner(
                    message: 'No se pudieron cargar los eventos. $err',
                  ),
                ),
              ),
              data: (eventos) {
                if (personaAsync.value == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Primero agregá una persona a cargo para ver sus eventos de salud.',
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

                // Filtro defensivo: nunca mostrar eventos con fecha futura.
                final ahora = DateTime.now();
                final eventosFiltrados = eventos
                    .where((e) => !e.fechaHora.isAfter(ahora))
                    .toList();

                if (eventosFiltrados.isEmpty) {
                  return _EmptyMonthState(puede: puede);
                }

                onTap(EventoSalud e) => context.pushNamed(
                  AppRoutes.healthEventDetailName,
                  pathParameters: {'id': e.id.toString()},
                );
                Future<void> onRefresh() async {
                  ref.invalidate(eventosSaludDelMesProvider);
                  await ref.read(eventosSaludDelMesProvider.future);
                }

                return HealthEventsMonthList(
                  eventos: eventosFiltrados,
                  puedeRegistrar: puede,
                  onRefresh: onRefresh,
                  onEventoTap: onTap,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: puede
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoutes.healthEventsNewName),
              tooltip: 'Nuevo evento de salud',
              backgroundColor: context.colors.healthAccent,
              child: Icon(Icons.add, color: context.colors.onPrimary),
            )
          : null,
    );
  }
}

// ─── Estado vacío del mes ─────────────────────────────────────────────────────

class _EmptyMonthState extends StatelessWidget {
  const _EmptyMonthState({required this.puede});

  final bool puede;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_outline,
              size: 64,
              color: context.colors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sin eventos en este mes.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (puede)
              Text(
                'Usá el botón + para registrar el primer evento.',
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
}

// ─── Skeleton de carga ────────────────────────────────────────────────────────

class _EventosSkeleton extends StatelessWidget {
  const _EventosSkeleton();

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
