import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../screens/shared/initial_day_scroll_mixin.dart';
import 'health_event_card.dart';
import 'health_event_day_group_header.dart';

/// Lista mensual de eventos de salud agrupada por día (orden ascendente).
///
/// Widget compartido entre la pantalla de eventos (US-30) y el historial
/// (US-33). Encapsula el [RefreshIndicator], el [ListView], la agrupación por
/// día y el estado de expansión de cada grupo (hoy y mañana expandidos por
/// defecto). La expansión se reinicia al cambiar de mes.
class HealthEventsMonthList extends ConsumerStatefulWidget {
  const HealthEventsMonthList({
    super.key,
    required this.eventos,
    required this.onRefresh,
    this.puedeRegistrar = false,
    this.onEventoTap,
  });

  /// Eventos del mes ya cargados (se agrupan por día internamente).
  final List<EventoSalud> eventos;

  /// Callback del [RefreshIndicator].
  final Future<void> Function() onRefresh;

  /// Indica si el usuario puede registrar eventos (para gating de acciones).
  final bool puedeRegistrar;

  /// Callback opcional al tocar una card de evento.
  final void Function(EventoSalud evento)? onEventoTap;

  @override
  ConsumerState<HealthEventsMonthList> createState() =>
      _HealthEventsMonthListState();
}

class _HealthEventsMonthListState extends ConsumerState<HealthEventsMonthList>
    with InitialDayScrollMixin {
  /// Días actualmente expandidos (fecha truncada a año-mes-día).
  late Set<DateTime> _expandedDias;

  @override
  void initState() {
    super.initState();
    _expandedDias = _diasExpandidosPorDefecto();
  }

  @override
  void didUpdateWidget(covariant HealthEventsMonthList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Al recargar los eventos (refresco o cambio de datos) se habilita
    // nuevamente el scroll inicial al día objetivo.
    if (!identical(oldWidget.eventos, widget.eventos)) {
      reiniciarScrollInicial();
    }
  }

  /// Hoy y mañana (si pertenecen al mes visible se expandirán por defecto).
  Set<DateTime> _diasExpandidosPorDefecto() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return {today, today.add(const Duration(days: 1))};
  }

  /// Agrupa los eventos por día (fecha truncada a año-mes-día).
  Map<DateTime, List<EventoSalud>> _agruparPorDia(List<EventoSalud> eventos) {
    final Map<DateTime, List<EventoSalud>> grupos = {};
    for (final e in eventos) {
      final dt = e.fechaHora.toLocal();
      final dia = DateTime(dt.year, dt.month, dt.day);
      grupos.putIfAbsent(dia, () => []).add(e);
    }
    return grupos;
  }

  @override
  Widget build(BuildContext context) {
    // Al cambiar de mes, reinicia la expansión (hoy/mañana por defecto) y
    // rehabilita el scroll inicial al día objetivo.
    ref.listen(mesEventosSaludProvider, (_, _) {
      reiniciarScrollInicial();
      setState(() => _expandedDias = _diasExpandidosPorDefecto());
    });

    final mes = ref.watch(mesEventosSaludProvider);
    final grupos = _agruparPorDia(widget.eventos);
    final dias = grupos.keys.toList()..sort();

    // Scroll automático (una sola vez por carga) al día objetivo del mes
    // actual, alineándolo arriba del viewport.
    final diaObjetivo = calcularDiaObjetivo(dias, mes);
    scrollAlDiaObjetivoUnaVez(diaObjetivo);

    return RefreshIndicator(
      color: context.colors.healthAccent,
      onRefresh: widget.onRefresh,
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
          final eventosDelDia = grupos[dia]!;
          final expandido = _expandedDias.contains(dia);
          return Column(
            key: dia == diaObjetivo ? diaObjetivoKey : null,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HealthEventDayGroupHeader(
                fecha: dia,
                count: eventosDelDia.length,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: eventosDelDia
                            .map(
                              (e) => HealthEventCard(
                                evento: e,
                                mostrarFecha: false,
                                tieneNotas: e.tieneNotas,
                                onTap: widget.onEventoTap == null
                                    ? () {}
                                    : () => widget.onEventoTap!(e),
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
  }
}
