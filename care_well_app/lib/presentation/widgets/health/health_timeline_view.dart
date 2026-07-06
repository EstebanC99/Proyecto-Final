import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'health_timeline_tile.dart';

/// Vista de línea de tiempo de salud en orden cronológico ascendente.
///
/// Renderiza los [EventoBase] (hábitos realizados, eventos de salud y estados
/// de ánimo mezclados) como una secuencia de [HealthTimelineTile] con
/// separadores de día discretos cuando cambia la fecha respecto del anterior.
class HealthTimelineView extends StatelessWidget {
  const HealthTimelineView({
    super.key,
    required this.eventos,
    required this.onRefresh,
  });

  /// Eventos del mes ya cargados (se ordenan por fecha internamente).
  final List<EventoBase> eventos;

  /// Callback del [RefreshIndicator].
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final ordenados = [...eventos]
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));

    return RefreshIndicator(
      color: AppColors.healthAccent,
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        itemCount: ordenados.length,
        itemBuilder: (context, i) {
          final evento = ordenados[i];
          final mostrarSeparador =
              i == 0 ||
              !_mismoDia(ordenados[i - 1].fechaHora, evento.fechaHora);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mostrarSeparador)
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 4, left: 40),
                  child: Text(
                    DateFormat(
                      'EEEE d',
                      'es',
                    ).format(evento.fechaHora.toLocal()),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
              HealthTimelineTile(
                evento: evento,
                isLast: i == ordenados.length - 1,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Indica si dos fechas corresponden al mismo día calendario (hora local).
  bool _mismoDia(DateTime a, DateTime b) {
    final la = a.toLocal();
    final lb = b.toLocal();
    return la.year == lb.year && la.month == lb.month && la.day == lb.day;
  }
}
