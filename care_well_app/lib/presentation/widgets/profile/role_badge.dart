import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Chip pequeño que muestra el rol del usuario en el sistema.
///
/// Fondo [AppColors.primaryContainer], texto [AppColors.primary], 12 sp, weight 600.
class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.rol});

  /// Texto del rol a mostrar (ej: "Responsable", "Cuidador").
  final String rol;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        rol,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
