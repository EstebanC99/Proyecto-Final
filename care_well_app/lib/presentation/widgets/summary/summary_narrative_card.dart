import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Tarjeta con el bloque narrativo del resumen (US 9.16).
///
/// Superficie blanca; muestra el texto devuelto por el backend tal cual, sin
/// desglosarlo por día ni por fuente (no hay estructura de días). El texto es
/// seleccionable.
class SummaryNarrativeCard extends StatelessWidget {
  const SummaryNarrativeCard({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppSpacing.elev1,
      ),
      child: SelectableText(
        texto,
        style: const TextStyle(
          fontSize: 15,
          height: 1.55,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
