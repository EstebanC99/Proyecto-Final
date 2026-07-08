import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/constraints/health_catalogs.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Selector de Factor sanguíneo: grilla 4×2 de chips de selección única.
///
/// Es obligatorio. Si [showError] es `true`, todos los chips muestran borde de
/// error y se agrega un texto de ayuda debajo.
class BloodTypeChipGrid extends StatelessWidget {
  const BloodTypeChipGrid({
    super.key,
    required this.selected,
    required this.onSelected,
    this.showError = false,
    this.enabled = true,
  });

  /// Valor seleccionado (null si ninguno).
  final String? selected;

  /// Callback al tocar un chip.
  final ValueChanged<String> onSelected;

  /// Si `true`, resalta el grid como campo obligatorio no completado.
  final bool showError;

  /// Cuando es `false`, los chips no responden al tap (modo solo lectura).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.9,
          children: [
            for (final valor in FactoresSanguineos.valores)
              _BloodChip(
                label: valor,
                selected: valor == selected,
                showError: showError,
                onTap: enabled
                    ? () {
                        HapticFeedback.selectionClick();
                        onSelected(valor);
                      }
                    : null,
              ),
          ],
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              'Seleccioná el factor sanguíneo',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _BloodChip extends StatelessWidget {
  const _BloodChip({
    required this.label,
    required this.selected,
    required this.showError,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool showError;

  /// `null` deshabilita el chip (modo solo lectura).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor;
    final double borderWidth;
    final Color bgColor;
    final Color textColor;

    if (selected) {
      borderColor = AppColors.healthAccent;
      borderWidth = 2;
      bgColor = AppColors.healthContainer;
      textColor = AppColors.healthAccent;
    } else if (showError) {
      borderColor = AppColors.error;
      borderWidth = 2;
      bgColor = AppColors.surface;
      textColor = AppColors.textPrimary;
    } else {
      borderColor = AppColors.outline;
      borderWidth = 1.5;
      bgColor = AppColors.surface;
      textColor = AppColors.textPrimary;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
