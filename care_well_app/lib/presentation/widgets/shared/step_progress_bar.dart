import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Barra de progreso de pasos para flujos multi-pantalla.
///
/// Muestra [totalSteps] segmentos lineales coloreados según si el paso
/// ya fue alcanzado ([currentStep]) o no. También muestra el contador
/// textual "Paso N de [totalSteps]".
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  }) : assert(
         currentStep >= 1 && currentStep <= totalSteps,
         'currentStep debe estar entre 1 y totalSteps',
       );

  /// Paso actual (1-based).
  final int currentStep;

  /// Total de pasos del flujo.
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Segmentos
        Expanded(
          child: Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index < currentStep;
              final isLast = index == totalSteps - 1;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: isLast ? 0 : AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        // Texto contador
        Text(
          'Paso $currentStep de $totalSteps',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
