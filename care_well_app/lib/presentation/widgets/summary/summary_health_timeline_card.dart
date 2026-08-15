import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'summary_section_card.dart';

/// Card "Salud" del Resumen (US 9.16): línea de tiempo de los eventos de salud
/// del día, con la hora a la izquierda y un pin sobre el hilo vertical.
///
/// No reutiliza `HealthTimelineTile`: esa fila trabaja con `EventoBase` y
/// colorea por categoría, mientras que acá el dato son textos sueltos generados
/// por el resumen y todos los pines comparten color (no hay severidad).
class SummaryHealthTimelineCard extends StatelessWidget {
  const SummaryHealthTimelineCard({
    super.key,
    required this.eventos,
    this.delay = Duration.zero,
  });

  final List<EventoSaludResumen> eventos;

  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final cantidad = eventos.length;

    return SummarySectionCard(
      icon: Icons.favorite_outline,
      iconColor: context.colors.healthAccent,
      iconBackgroundColor: context.colors.healthContainer,
      title: 'Salud',
      meta: cantidad == 1 ? '1 registro' : '$cantidad registros',
      delay: delay,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (indice, evento) in eventos.indexed)
            _EventoRow(evento: evento, esUltimo: indice == eventos.length - 1),
        ],
      ),
    );
  }
}

/// Fila de un evento: hora · pin · descripción (+ hábito asociado).
class _EventoRow extends StatelessWidget {
  const _EventoRow({required this.evento, required this.esUltimo});

  final EventoSaludResumen evento;
  final bool esUltimo;

  /// Ancho del canal de la hora con la escala tipográfica al 100%: los eventos
  /// sin hora dejan el hueco vacío para que la grilla no se desalinee.
  static const double _anchoHora = 42;

  /// Tope del canal: más ancho le comería demasiado a la descripción.
  static const double _anchoHoraMaximo = 72;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // El canal acompaña la escala tipográfica para que "08:45" no se parta en
    // dos líneas con el texto agrandado.
    final anchoHora = MediaQuery.textScalerOf(
      context,
    ).scale(_anchoHora).clamp(_anchoHora, _anchoHoraMaximo);

    return Semantics(
      label: [
        if (evento.hora != null) evento.hora,
        evento.descripcion,
        if (evento.actividadHabitoAsociado != null)
          evento.actividadHabitoAsociado,
      ].join(', '),
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: anchoHora,
              child: Text(
                evento.hora ?? '',
                textAlign: TextAlign.right,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            _Canal(esUltimo: esUltimo),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: esUltimo ? 0 : AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento.descripcion,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (evento.actividadHabitoAsociado != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        evento.actividadHabitoAsociado!,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.3,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Columna del pin y del hilo vertical que une los eventos.
class _Canal extends StatelessWidget {
  const _Canal({required this.esUltimo});

  final bool esUltimo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 11,
      child: Column(
        children: [
          Container(
            width: 11,
            height: 11,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.healthAccent, width: 3),
            ),
          ),
          if (!esUltimo)
            Expanded(
              child: Center(
                child: Container(width: 1.5, color: colors.outline),
              ),
            ),
        ],
      ),
    );
  }
}
