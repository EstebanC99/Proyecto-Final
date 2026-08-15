import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'summary_bullet_row.dart';
import 'summary_section_card.dart';

/// Card "A tener en cuenta" del Resumen (US 9.16).
///
/// Reúne dos grupos: las recomendaciones de seguimiento que redactó la IA y los
/// compromisos de la agenda de hoy que todavía no ocurrieron. Cada grupo se
/// pinta solo si tiene contenido; el divisor aparece únicamente cuando están
/// los dos.
class SummaryAttentionCard extends StatelessWidget {
  const SummaryAttentionCard({
    super.key,
    this.recomendaciones = const [],
    this.recordatoriosHoy = const [],
    this.delay = Duration.zero,
  });

  final List<String> recomendaciones;
  final List<String> recordatoriosHoy;

  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hayRecomendaciones = recomendaciones.isNotEmpty;
    final hayRecordatorios = recordatoriosHoy.isNotEmpty;

    return SummarySectionCard(
      icon: Icons.warning_amber_rounded,
      iconColor: colors.warning,
      iconBackgroundColor: colors.surface,
      title: 'A tener en cuenta',
      variant: SummarySectionVariant.warning,
      delay: delay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hayRecomendaciones)
            _Grupo(
              items: recomendaciones,
              bulletColor: colors.warning,
              textColor: colors.textPrimary,
            ),
          if (hayRecomendaciones && hayRecordatorios) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(color: colors.warning.withValues(alpha: 0.4), height: 1),
            const SizedBox(height: AppSpacing.md),
          ],
          if (hayRecordatorios) ...[
            Text(
              'Pendientes de hoy',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _Grupo(
              items: recordatoriosHoy,
              bulletColor: colors.warning,
              textColor: colors.textPrimary,
            ),
          ],
        ],
      ),
    );
  }
}

/// Lista de viñetas de un grupo.
class _Grupo extends StatelessWidget {
  const _Grupo({
    required this.items,
    required this.bulletColor,
    required this.textColor,
  });

  final List<String> items;
  final Color bulletColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (indice, item) in items.indexed) ...[
          if (indice > 0) const SizedBox(height: AppSpacing.md),
          SummaryBulletRow(
            texto: item,
            bulletColor: bulletColor,
            textColor: textColor,
          ),
        ],
      ],
    );
  }
}
