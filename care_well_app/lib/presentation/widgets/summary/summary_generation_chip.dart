import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
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
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Generado ${_relativo(generadoEn)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Devuelve una etiqueta de tiempo relativo simple para el momento de
  /// generación (siempre en el pasado o "recién").
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
