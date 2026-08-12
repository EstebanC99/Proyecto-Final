import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Banda de progreso de los hábitos del día, fija bajo el AppBar.
///
/// Muestra "N de M hábitos de hoy" y una barra segmentada: un segmento por
/// hábito, pintados los completados. Es un widget tonto: recibe los números ya
/// calculados (ver `progresoHabitosHoyProvider`).
class HabitsDayProgressHeader extends StatelessWidget {
  const HabitsDayProgressHeader({
    super.key,
    required this.completados,
    required this.total,
  });

  /// Cantidad de hábitos realizados hoy.
  final int completados;

  /// Cantidad total de hábitos de la persona.
  final int total;

  /// A partir de esta cantidad de hábitos los segmentos quedarían demasiado
  /// finos, así que se dibuja una sola barra con relleno proporcional.
  static const int _maxSegmentos = 12;

  /// Alto de la barra de progreso.
  static const double _altoBarra = 8;

  /// Separación entre segmentos.
  static const double _gapSegmentos = 5;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$completados de $total hábitos completados hoy',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(bottom: BorderSide(color: context.colors.outline)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$completados de $total',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      'hábitos de hoy',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ExcludeSemantics(
              child: total > _maxSegmentos
                  ? _BarraContinua(completados: completados, total: total)
                  : _BarraSegmentada(completados: completados, total: total),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barra con un segmento por hábito: la lectura es "cuántos me faltan".
class _BarraSegmentada extends StatelessWidget {
  const _BarraSegmentada({required this.completados, required this.total});

  final int completados;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0)
            const SizedBox(width: HabitsDayProgressHeader._gapSegmentos),
          Expanded(
            child: Container(
              height: HabitsDayProgressHeader._altoBarra,
              decoration: BoxDecoration(
                color: i < completados
                    ? context.colors.habitsAccent
                    : context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(
                  HabitsDayProgressHeader._altoBarra / 2,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Barra única con relleno proporcional, para cuando hay tantos hábitos que
/// los segmentos individuales quedarían como astillas de pocos píxeles.
class _BarraContinua extends StatelessWidget {
  const _BarraContinua({required this.completados, required this.total});

  final int completados;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraccion = total == 0 ? 0.0 : (completados / total).clamp(0.0, 1.0);
    return Container(
      height: HabitsDayProgressHeader._altoBarra,
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(
          HabitsDayProgressHeader._altoBarra / 2,
        ),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraccion,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.habitsAccent,
            borderRadius: BorderRadius.circular(
              HabitsDayProgressHeader._altoBarra / 2,
            ),
          ),
        ),
      ),
    );
  }
}
