import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Chip que informa cuándo se generó el resumen (US 9.16), ej. "Generado hace
/// 3 min". El tiempo relativo se calcula respecto de [generadoEn] al construir.
class SummaryGenerationChip extends StatelessWidget {
  const SummaryGenerationChip({super.key, required this.generadoEn});

  final DateTime generadoEn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 14, color: context.colors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Generado ${_relativo(generadoEn)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Devuelve una etiqueta de tiempo relativo simple para el momento de
  /// generación (siempre en el pasado o "recién").
  ///
  /// El backend sella la fecha con la hora del servidor, que puede no coincidir
  /// con la del teléfono (distinta zona horaria o reloj desfasado). Por eso las
  /// diferencias negativas —fechas "en el futuro"— también se muestran como
  /// "recién" en lugar de un texto absurdo.
  static String _relativo(DateTime momento) {
    final diff = DateTime.now().difference(momento);
    if (diff.inMinutes < 1) return 'recién';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'hace $m min';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'hace $h ${h == 1 ? 'hora' : 'horas'}';
    }
    final d = diff.inDays;
    return 'hace $d ${d == 1 ? 'día' : 'días'}';
  }
}
