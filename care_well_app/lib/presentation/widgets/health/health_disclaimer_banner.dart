import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Banner prominente con el aviso legal sobre recomendaciones médicas.
///
/// Aparece en la pantalla de recomendaciones para aclarar que no reemplazan
/// la consulta con un profesional de la salud.
class HealthDisclaimerBanner extends StatelessWidget {
  const HealthDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.warningContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: context.colors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: context.colors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Las recomendaciones no constituyen diagnóstico ni reemplazan '
              'la consulta con un profesional de la salud.',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.warning.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
