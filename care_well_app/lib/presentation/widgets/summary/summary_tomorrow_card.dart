import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'summary_bullet_row.dart';
import 'summary_habit_chip.dart';
import 'summary_section_card.dart';

/// Card "Mañana" del Resumen (US 9.16): adelanto del día siguiente.
///
/// Arranca colapsada (es información secundaria) y se despliega al tocar el
/// encabezado. Muestra los recordatorios de agenda de mañana —o una línea
/// neutra si no hay— y las pills de los hábitos previstos, siempre pendientes.
class SummaryTomorrowCard extends StatefulWidget {
  const SummaryTomorrowCard({
    super.key,
    this.recordatorios = const [],
    this.habitos = const [],
    this.delay = Duration.zero,
  });

  final List<String> recordatorios;
  final List<HabitoResumen> habitos;

  final Duration delay;

  @override
  State<SummaryTomorrowCard> createState() => _SummaryTomorrowCardState();
}

class _SummaryTomorrowCardState extends State<SummaryTomorrowCard> {
  bool _expandida = false;

  void _toggle() => setState(() => _expandida = !_expandida);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sinAnimacion = MediaQuery.disableAnimationsOf(context);
    final duracion = Duration(milliseconds: sinAnimacion ? 0 : 250);
    final cantidadHabitos = widget.habitos.length;

    return SummarySectionCard(
      icon: Icons.event_outlined,
      iconColor: colors.textSecondary,
      iconBackgroundColor: colors.surfaceVariant,
      title: 'Mañana',
      meta: cantidadHabitos == 0
          ? null
          : (cantidadHabitos == 1 ? '1 hábito' : '$cantidadHabitos hábitos'),
      delay: widget.delay,
      onTapHeader: _toggle,
      expandido: _expandida,
      // El chevron es decorativo: el estado lo anuncia la card como botón
      // contraído/expandido.
      trailing: AnimatedRotation(
        turns: _expandida ? 0.5 : 0,
        duration: duracion,
        child: Icon(Icons.expand_more, size: 22, color: colors.textSecondary),
      ),
      contentPadding: EdgeInsets.zero,
      child: AnimatedSize(
        duration: duracion,
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: _expandida
            ? Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.recordatorios.isEmpty)
                      Text(
                        'Sin turnos ni recordatorios agendados.',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: colors.textSecondary,
                        ),
                      )
                    else
                      for (final (indice, item)
                          in widget.recordatorios.indexed) ...[
                        if (indice > 0) const SizedBox(height: AppSpacing.sm),
                        SummaryBulletRow(texto: item),
                      ],
                    if (widget.habitos.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final habito in widget.habitos)
                            SummaryHabitChip(habito: habito),
                        ],
                      ),
                    ],
                  ],
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}
