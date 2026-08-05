import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Disclaimer de contenido generado por IA para la pantalla de Resumen (US 9.16).
///
/// Fondo [AppPalette.aiContainer], ícono `auto_awesome` y chip "IA". Deja claro
/// el carácter no clínico del resumen. El screen decide cuándo mostrarlo: se
/// oculta cuando no hay datos (no se generó nada por IA).
class AiDisclaimerCard extends StatelessWidget {
  const AiDisclaimerCard({super.key});

  static const String _texto =
      'Resumen generado automáticamente a partir de tus registros de salud, '
      'hábitos y estados de ánimo. No es un diagnóstico ni reemplaza la '
      'consulta con un profesional de salud.';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.aiContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, size: 20, color: context.colors.aiAccent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AiChip(),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _texto,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip compacto "IA" con el acento de contenido generado.
class _AiChip extends StatelessWidget {
  const _AiChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.aiAccent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        'IA',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: context.colors.onPrimary,
        ),
      ),
    );
  }
}
