import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Pie de la pantalla de Resumen (US 9.16).
///
/// Declara la procedencia del contenido (generado por IA) y su carácter no
/// clínico. Es el único sello de IA de la pantalla: al pie y en gris no compite
/// con las cards, y acompaña a todos los estados con datos. El ícono repite la
/// marca en clave visual, para que no dependa solo de la lectura del texto.
class SummaryFooterDisclaimer extends StatelessWidget {
  const SummaryFooterDisclaimer({super.key});

  static const String texto =
      'Resumen generado automáticamente por IA a partir de tus registros de '
      'salud, hábitos y estados de ánimo. No es un diagnóstico ni reemplaza la '
      'consulta con un profesional de salud.';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decorativo: el texto de al lado ya dice que lo generó una IA.
          ExcludeSemantics(
            child: Icon(Icons.auto_awesome, size: 16, color: colors.aiAccent),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 11,
                height: 1.5,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
