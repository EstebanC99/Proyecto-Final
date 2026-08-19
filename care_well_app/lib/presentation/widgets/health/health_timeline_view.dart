import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'health_timeline_tile.dart';
import 'timeline_grouping.dart';

/// Vista de línea de tiempo de salud, agrupada por día.
///
/// Los días van del más reciente al más antiguo y, dentro de cada uno, los
/// registros de la mañana a la noche. Lo último registrado queda arriba sin
/// necesidad de mover la lista: antes se saltaba al fondo tras cada carga, lo
/// que además pisaba la posición del usuario en cada refresh.
///
/// Recibe los grupos ya armados ([agruparPorDia]) en vez de calcularlos: así no
/// se reagrupa en cada rebuild y el widget se puede probar aislado.
class HealthTimelineView extends StatelessWidget {
  const HealthTimelineView({
    super.key,
    required this.grupos,
    required this.onRefresh,
  });

  /// Registros del mes agrupados por día.
  final List<GrupoDiaTimeline> grupos;

  /// Callback del [RefreshIndicator].
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: context.colors.healthAccent,
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        itemCount: grupos.length,
        itemBuilder: (context, i) {
          final grupo = grupos[i];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 4, left: 40),
                child: Text(
                  DateFormat('EEEE d', 'es').format(grupo.dia),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: context.colors.textDisabled,
                  ),
                ),
              ),
              for (var j = 0; j < grupo.eventos.length; j++)
                HealthTimelineTile(
                  // `EventoBase.id` no es único entre categorías: un hábito y
                  // un ánimo pueden compartirlo.
                  key: ValueKey(
                    '${grupo.eventos[j].categoriaEvento}-${grupo.eventos[j].id}',
                  ),
                  evento: grupo.eventos[j],
                  isLast: j == grupo.eventos.length - 1,
                ),
            ],
          );
        },
      ),
    );
  }
}
