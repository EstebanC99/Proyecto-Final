import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Sección de configuración con encabezado y lista de ítems.
///
/// El [title] se muestra en mayúsculas, 12 sp, color [AppPalette.textSecondary].
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: context.colors.outline),
        ...items,
      ],
    );
  }
}
