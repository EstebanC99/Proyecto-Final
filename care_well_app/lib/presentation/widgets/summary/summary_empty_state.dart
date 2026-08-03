import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Estado vacío de la pantalla de Resumen (US 9.16), cuando la persona no tiene
/// datos en ninguno de los tres orígenes del día. Neutro: no menciona a la IA
/// (no se generó nada). Se muestra en lugar de la narrativa y el disclaimer.
class SummaryEmptyState extends StatelessWidget {
  const SummaryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.aiContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 34,
                color: AppColors.aiAccent,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Nada para resumir todavía',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Cuando registres eventos de salud, hábitos o estados de ánimo '
              'del día, vas a poder generar un resumen acá.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
