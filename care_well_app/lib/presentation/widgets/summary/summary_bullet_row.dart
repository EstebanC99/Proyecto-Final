import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Ítem con viñeta de las listas de texto del Resumen (US 9.16).
///
/// Lo comparten la card "A tener en cuenta" y la de "Mañana": solo cambian los
/// colores de la viñeta y del texto.
class SummaryBulletRow extends StatelessWidget {
  const SummaryBulletRow({
    super.key,
    required this.texto,
    this.bulletColor,
    this.textColor,
  });

  final String texto;

  /// Color de la viñeta. Por defecto, [AppPalette.textSecondary].
  final Color? bulletColor;

  /// Color del texto. Por defecto, [AppPalette.textPrimary].
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w700,
            color: bulletColor ?? colors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: textColor ?? colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
