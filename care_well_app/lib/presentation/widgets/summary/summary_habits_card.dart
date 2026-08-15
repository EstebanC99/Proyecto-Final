import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'habits_progress_ring.dart';
import 'summary_habit_chip.dart';
import 'summary_section_card.dart';

/// Card "Hábitos de hoy" del Resumen (US 9.16).
///
/// Anillo de progreso + comentario redactado por la IA y, debajo, una pill por
/// hábito con su estado. Los totales llegan calculados desde la entidad.
///
/// Cuando el resumen trae el comentario pero no la lista de hábitos (el modelo
/// puede redactar uno sin la otra), la card se reduce al comentario: sin anillo
/// —no habría progreso que mostrar—, sin pills y sin la meta "0 de 0".
class SummaryHabitsCard extends StatelessWidget {
  const SummaryHabitsCard({
    super.key,
    required this.habitos,
    required this.completados,
    required this.progreso,
    this.resumen,
    this.delay = Duration.zero,
  });

  /// Hábitos previstos para hoy.
  final List<HabitoResumen> habitos;

  /// Hábitos ya registrados como realizados ([ResumenInteligente.habitosCompletados]).
  final int completados;

  /// Avance entre 0.0 y 1.0 ([ResumenInteligente.progresoHabitos]).
  final double progreso;

  /// Comentario del resumen sobre los hábitos del día, si lo hay.
  final String? resumen;

  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final total = habitos.length;
    final hayLista = habitos.isNotEmpty;

    final comentario = resumen == null
        ? null
        : Text(
            resumen!,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: context.colors.textSecondary,
            ),
          );

    return SummarySectionCard(
      icon: Icons.check_circle_outline,
      iconColor: context.colors.habitsAccent,
      iconBackgroundColor: context.colors.habitsContainer,
      title: 'Hábitos de hoy',
      meta: hayLista ? '$completados de $total' : null,
      delay: delay,
      // Sin lista ni comentario no hay cuerpo: la card queda solo con el
      // encabezado (caso que la pantalla ya evita con `hayHabitos`).
      child: !hayLista && comentario == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hayLista)
                  comentario!
                else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      HabitsProgressRing(
                        completados: completados,
                        total: total,
                        progreso: progreso,
                      ),
                      if (comentario != null) ...[
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(child: comentario),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final habito in habitos)
                        SummaryHabitChip(habito: habito),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
