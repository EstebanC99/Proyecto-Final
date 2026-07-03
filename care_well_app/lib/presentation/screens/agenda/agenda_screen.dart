import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla principal de la agenda (US-23 / US-27).
///
/// Muestra las ocurrencias de eventos del mes seleccionado para la persona de
/// contexto, agrupadas por día. Permite navegar entre meses y, para usuarios
/// con permiso [PermisosCuidadoConst.gestionarAgenda], crear, editar, cancelar
/// y eliminar eventos.
class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  /// Días actualmente expandidos (fecha truncada a año-mes-día).
  late Set<DateTime> _expandedDias;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _expandedDias = {today, today.add(const Duration(days: 1))};
  }

  /// Agrupa las ocurrencias por día (fecha truncada a año-mes-día).
  Map<DateTime, List<OcurrenciaEventoAgenda>> _agruparPorDia(
    List<OcurrenciaEventoAgenda> ocurrencias,
  ) {
    final Map<DateTime, List<OcurrenciaEventoAgenda>> grupos = {};
    for (final o in ocurrencias) {
      final dt = o.fechaHoraInicio.toLocal();
      final dia = DateTime(dt.year, dt.month, dt.day);
      grupos.putIfAbsent(dia, () => []).add(o);
    }
    return grupos;
  }

  void _irAMesAnterior() {
    final mes = ref.read(mesSeleccionadoProvider);
    ref.read(mesSeleccionadoProvider.notifier).state = DateTime(
      mes.year,
      mes.month - 1,
      1,
    );
  }

  void _irAMesSiguiente() {
    final mes = ref.read(mesSeleccionadoProvider);
    ref.read(mesSeleccionadoProvider.notifier).state = DateTime(
      mes.year,
      mes.month + 1,
      1,
    );
  }

  Future<void> _resolverAccion(
    BuildContext context,
    OcurrenciaEventoAgenda ocurrencia,
  ) async {
    final accion = await OcurrenciaActionSheet.show(
      context,
      ocurrencia: ocurrencia,
    );
    if (accion == null || !context.mounted) return;

    switch (accion) {
      case OcurrenciaAccion.editar:
        context.pushNamed(
          AppRoutes.agendaEventName,
          pathParameters: {'id': ocurrencia.eventoAgendaId.toString()},
        );
      case OcurrenciaAccion.cancelarOcurrencia:
        await _confirmarCancelarOcurrencia(context, ocurrencia);
      case OcurrenciaAccion.eliminar:
        await _confirmarEliminar(context, ocurrencia);
    }
  }

  Future<void> _confirmarCancelarOcurrencia(
    BuildContext context,
    OcurrenciaEventoAgenda ocurrencia,
  ) async {
    await ConfirmDialog.show(
      context,
      title: '¿Cancelar esta ocurrencia?',
      body:
          'Se cancelará únicamente el evento del día seleccionado. El resto de '
          'la serie se mantiene.',
      confirmLabel: 'Cancelar ocurrencia',
      icon: Icons.event_busy_outlined,
      onConfirm: () => ref.read(cancelarOcurrenciaProvider)(
        eventoAgendaId: ocurrencia.eventoAgendaId,
        fechaOcurrencia: ocurrencia.fechaHoraInicio,
      ),
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    OcurrenciaEventoAgenda ocurrencia,
  ) async {
    await ConfirmDialog.show(
      context,
      title: ocurrencia.esRecurrente
          ? '¿Eliminar toda la serie?'
          : '¿Eliminar evento?',
      body: ocurrencia.esRecurrente
          ? 'Se eliminarán todas las ocurrencias de este evento recurrente. '
                'Esta acción no se puede deshacer.'
          : 'Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      icon: Icons.delete_outline,
      onConfirm: () =>
          ref.read(eliminarEventoAgendaProvider)(ocurrencia.eventoAgendaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final personaAsync = ref.watch(agendaPersonaContextProvider);
    final ocurrenciasAsync = ref.watch(ocurrenciasDelMesProvider);
    final mes = ref.watch(mesSeleccionadoProvider);
    final puedeGestionar =
        ref.watch(puedeGestionarAgendaProvider).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Calendario'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de persona de contexto (solo si hay persona).
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

          // Navegación mensual.
          MonthNavHeader(
            mes: mes,
            onPrevious: _irAMesAnterior,
            onNext: _irAMesSiguiente,
          ),

          Expanded(
            child: ocurrenciasAsync.when(
              loading: () => const _OcurrenciasSkeleton(),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: InlineErrorBanner(
                    message: 'No se pudo cargar la agenda. $err',
                  ),
                ),
              ),
              data: (ocurrencias) {
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

                if (ocurrencias.isEmpty) {
                  return AgendaEmptyState(
                    puedeGestionar: puedeGestionar,
                    onCrear: puedeGestionar
                        ? () => context.pushNamed(AppRoutes.agendaNewName)
                        : null,
                  );
                }

                final grupos = _agruparPorDia(ocurrencias);
                final dias = grupos.keys.toList()..sort();

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(ocurrenciasDelMesProvider);
                    await ref.read(ocurrenciasDelMesProvider.future);
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                    ),
                    itemCount: dias.length,
                    itemBuilder: (context, i) {
                      final dia = dias[i];
                      final ocurrenciasDelDia = grupos[dia]!;
                      final expandido = _expandedDias.contains(dia);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DayGroupHeader(
                            fecha: dia,
                            count: ocurrenciasDelDia.length,
                            expanded: expandido,
                            onTap: () => setState(() {
                              if (_expandedDias.contains(dia)) {
                                _expandedDias.remove(dia);
                              } else {
                                _expandedDias.add(dia);
                              }
                            }),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            child: expandido
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: ocurrenciasDelDia
                                        .map(
                                          (o) => OcurrenciaCard(
                                            ocurrencia: o,
                                            onTap:
                                                puedeGestionar && o.esEditable()
                                                ? () => _resolverAccion(
                                                    context,
                                                    o,
                                                  )
                                                : null,
                                          ),
                                        )
                                        .toList(),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      );
                    },
                  ),
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

// ─── Skeleton de carga ────────────────────────────────────────────────────────

class _OcurrenciasSkeleton extends StatelessWidget {
  const _OcurrenciasSkeleton();

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
          (_) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            height: 84,
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

// ─── Encabezado de grupo por día (colapsable) ─────────────────────────────────

class _DayGroupHeader extends StatelessWidget {
  const _DayGroupHeader({
    required this.fecha,
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final DateTime fecha;
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  static const _meses = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];
  static const _diasSemana = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final day = DateTime(fecha.year, fecha.month, fecha.day);
    if (day == today) return 'HOY';
    if (day == tomorrow) return 'MAÑANA';
    return '${_diasSemana[fecha.weekday - 1]} ${fecha.day} de ${_meses[fecha.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _label().toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (!expanded) ...[
              Text(
                '$count ${count == 1 ? "evento" : "eventos"}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              expanded
                  ? Icons.expand_more_rounded
                  : Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
