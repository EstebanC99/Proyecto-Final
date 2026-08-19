import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'day_group_header.dart';
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

  /// Cantidad de grupos que entran con animación de aparición.
  ///
  /// Sólo los primeros: dentro de un `ListView.builder` los ítems se
  /// reconstruyen al volver a entrar en pantalla, y animarlos todos haría que
  /// la lista parpadee en cada scroll.
  static const _gruposAnimados = 3;

  /// Registros del mes agrupados por día.
  final List<GrupoDiaTimeline> grupos;

  /// Callback del [RefreshIndicator].
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final sinAnimacion = MediaQuery.disableAnimationsOf(context);

    return RefreshIndicator(
      color: context.colors.healthAccent,
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        itemCount: grupos.length,
        itemBuilder: (context, i) {
          final grupo = _GrupoDia(grupo: grupos[i]);
          if (sinAnimacion || i >= _gruposAnimados) return grupo;

          return FadeInUp(
            duration: const Duration(milliseconds: 400),
            delay: Duration(milliseconds: 50 * i),
            from: 12,
            child: grupo,
          );
        },
      ),
    );
  }
}

/// Un día: encabezado y la tarjeta con sus registros.
class _GrupoDia extends StatelessWidget {
  const _GrupoDia({required this.grupo});

  final GrupoDiaTimeline grupo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DayGroupHeader(dia: grupo.dia, cantidad: grupo.eventos.length),
          const SizedBox(height: 9),
          // Una sola tarjeta por día con las filas adentro. El `clipBehavior`
          // recorta el radio: sin él, la primera y la última fila pisan las
          // esquinas redondeadas.
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppSpacing.elev1,
            ),
            child: Column(
              children: [
                for (var j = 0; j < grupo.eventos.length; j++) ...[
                  if (j > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.colors.surfaceVariant,
                    ),
                  HealthTimelineTile(
                    // `EventoBase.id` no es único entre categorías: un hábito y
                    // un ánimo pueden compartirlo.
                    key: ValueKey(
                      '${grupo.eventos[j].categoriaEvento}-'
                      '${grupo.eventos[j].id}',
                    ),
                    evento: grupo.eventos[j],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
