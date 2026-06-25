import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla principal de la agenda (US-23 y US-27).
///
/// Muestra la lista de eventos agrupados por fecha para la persona de contexto.
/// Los eventos vencidos se muestran con opacidad reducida y ícono de candado.
/// Solo los usuarios con permiso [CodigoPermiso.gestionarAgenda] pueden crear,
/// editar o eliminar eventos.
class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  /// Agrupa una lista de eventos por día (año-mes-día truncado).
  Map<DateTime, List<EventoAgenda>> _agruparPorDia(List<EventoAgenda> eventos) {
    final Map<DateTime, List<EventoAgenda>> grupos = {};
    for (final e in eventos) {
      final dt = e.fechaHoraInicio.toLocal();
      final dia = DateTime(dt.year, dt.month, dt.day);
      grupos.putIfAbsent(dia, () => []).add(e);
    }
    return grupos;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaAsync = ref.watch(agendaPersonaContextProvider);
    final eventosAsync = ref.watch(agendaEventosProvider);
    final puedeGestionarAsync = ref.watch(puedeGestionarAgendaProvider);

    final puedeGestionar = puedeGestionarAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (puedeGestionar)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Nuevo evento',
              onPressed: () => context.pushNamed(AppRoutes.agendaNewName),
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
                      0,
                    ),
                    child: ContextSelector(),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),

          // Lista de eventos
          Expanded(
            child: eventosAsync.when(
              loading: () => _EventosSkeleton(),
              error: (err, _) => Center(
                child: InlineErrorBanner(
                  message: 'No se pudo cargar la agenda. $err',
                ),
              ),
              data: (eventos) {
                // Sin persona de contexto
                if (personaAsync.valueOrNull == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Primero agregá una persona a cargo para ver su agenda.',
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

                // Sin eventos
                if (eventos.isEmpty) {
                  return AgendaEmptyState(
                    puedeGestionar: puedeGestionar,
                    onCrear: puedeGestionar
                        ? () => context.pushNamed(AppRoutes.agendaNewName)
                        : null,
                  );
                }

                // Lista agrupada
                final grupos = _agruparPorDia(eventos);
                final dias = grupos.keys.toList()..sort();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  itemCount: dias.length,
                  itemBuilder: (context, i) {
                    final dia = dias[i];
                    final eventosDelDia = grupos[dia]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DateGroupLabel(fecha: dia),
                        ...eventosDelDia.map(
                          (e) => _EventCardConRecordatorio(
                            evento: e,
                            onTap: () => context.pushNamed(
                              AppRoutes.agendaEventName,
                              pathParameters: {'id': e.id.toString()},
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: puedeGestionar
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoutes.agendaNewName),
              tooltip: 'Nuevo evento',
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.onPrimary),
            )
          : null,
    );
  }
}

// ─── Subwidget: EventCard conectado a su recordatorio ────────────────────────

class _EventCardConRecordatorio extends ConsumerWidget {
  const _EventCardConRecordatorio({required this.evento, required this.onTap});

  final EventoAgenda evento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordatoriosAsync = ref.watch(
      recordatoriosByEventoProvider(evento.id),
    );
    final tieneRecordatorio =
        recordatoriosAsync.valueOrNull?.isNotEmpty ?? false;

    return EventCard(
      evento: evento,
      tieneRecordatorio: tieneRecordatorio,
      onTap: onTap,
    );
  }
}

// ─── Skeleton de carga ────────────────────────────────────────────────────────

class _EventosSkeleton extends StatelessWidget {
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
        children: List.generate(
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
      ),
    );
  }
}
