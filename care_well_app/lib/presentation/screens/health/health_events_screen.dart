import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Modo de visualización de los eventos de salud.
enum _HealthEventsViewMode { lista, timeline }

/// Lista mensual de eventos de salud agrupada por día (US-30).
///
/// Muestra los eventos del mes seleccionado para la persona de contexto,
/// agrupados por día en orden ascendente. Permite navegar entre meses,
/// alternar entre vista de lista y línea de tiempo, y —para usuarios con
/// permiso [PermisosCuidadoConst.registrarEventosSalud]— registrar nuevos
/// eventos mediante el FAB.
class HealthEventsScreen extends ConsumerStatefulWidget {
  const HealthEventsScreen({super.key});

  @override
  ConsumerState<HealthEventsScreen> createState() => _HealthEventsScreenState();
}

class _HealthEventsScreenState extends ConsumerState<HealthEventsScreen> {
  _HealthEventsViewMode _vista = _HealthEventsViewMode.lista;

  void _irMesAnterior() {
    final mes = ref.read(mesEventosSaludProvider);
    ref.read(mesEventosSaludProvider.notifier).state = DateTime(
      mes.year,
      mes.month - 1,
      1,
    );
  }

  void _irMesSiguiente() {
    final mes = ref.read(mesEventosSaludProvider);
    ref.read(mesEventosSaludProvider.notifier).state = DateTime(
      mes.year,
      mes.month + 1,
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventosAsync = ref.watch(eventosSaludDelMesProvider);
    final puede =
        ref.watch(puedeRegistrarEventosSaludProvider).valueOrNull ?? false;
    final personaAsync = ref.watch(healthPersonaContextProvider);
    final mes = ref.watch(mesEventosSaludProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Eventos de salud'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: _vista == _HealthEventsViewMode.lista
                ? 'Ver como línea de tiempo'
                : 'Ver como lista',
            icon: Icon(
              _vista == _HealthEventsViewMode.lista
                  ? Icons.timeline
                  : Icons.view_agenda_outlined,
            ),
            onPressed: () => setState(() {
              _vista = _vista == _HealthEventsViewMode.lista
                  ? _HealthEventsViewMode.timeline
                  : _HealthEventsViewMode.lista;
            }),
          ),
        ],
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

          // Navegación mensual
          MonthNavHeader(
            mes: mes,
            onPrevious: _irMesAnterior,
            onNext: _irMesSiguiente,
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
                if (personaAsync.valueOrNull == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Primero agregá una persona a cargo para ver sus eventos de salud.',
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
                  return _EmptyMonthState(puede: puede);
                }

                onTap(EventoDeSalud e) => context.pushNamed(
                  AppRoutes.healthEventDetailName,
                  pathParameters: {'id': e.id.toString()},
                );
                Future<void> onRefresh() async {
                  ref.invalidate(eventosSaludDelMesProvider);
                  await ref.read(eventosSaludDelMesProvider.future);
                }

                return switch (_vista) {
                  _HealthEventsViewMode.lista => HealthEventsMonthList(
                    eventos: eventos,
                    puedeRegistrar: puede,
                    onRefresh: onRefresh,
                    onEventoTap: onTap,
                  ),
                  _HealthEventsViewMode.timeline => HealthEventsTimelineView(
                    eventos: eventos,
                    onRefresh: onRefresh,
                    onEventoTap: onTap,
                  ),
                };
              },
            ),
          ),
        ],
      ),
      floatingActionButton: puede
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoutes.healthEventsNewName),
              tooltip: 'Nuevo evento de salud',
              backgroundColor: AppColors.healthAccent,
              child: const Icon(Icons.add, color: Colors.white),
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
            const Icon(
              Icons.favorite_outline,
              size: 64,
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Sin eventos en este mes.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (puede)
              const Text(
                'Usá el botón + para registrar el primer evento.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textDisabled),
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
