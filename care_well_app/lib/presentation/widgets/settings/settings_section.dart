import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Sección de configuración con encabezado y lista de ítems.
///
/// El [title] se muestra en mayúsculas, 12 sp, color [AppColors.textSecondary].
/// Los [items] se apilan en una [Column] bajo el encabezado.
class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.items});

  /// Título de la sección (se muestra en mayúsculas).
  final String title;

  /// Lista de ítems a mostrar bajo el encabezado.
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.xs,
          ),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.outline),
        ...items,
      ],
    );
  }
}
