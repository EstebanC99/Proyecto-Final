import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Chip pequeño que muestra el rol del usuario en el sistema.
///
/// Fondo [AppPalette.primaryContainer], texto [AppPalette.primary], 12 sp, weight 600.
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
        color: context.colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        rol,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: context.colors.primary,
        ),
      ),
    );
  }
}
