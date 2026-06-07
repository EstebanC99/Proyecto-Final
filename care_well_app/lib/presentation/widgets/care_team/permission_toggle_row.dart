import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Fila de permiso con toggle.
///
/// El tap en toda la fila (altura mínima 56 dp) invierte el estado del toggle.
class PermissionToggleRow extends StatelessWidget {
  const PermissionToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  /// Etiqueta descriptiva del permiso.
  final String label;

  /// Estado actual del permiso.
  final bool value;

  /// Callback al cambiar el estado.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}
