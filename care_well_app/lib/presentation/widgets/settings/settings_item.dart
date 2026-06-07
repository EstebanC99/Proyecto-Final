import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Ítem de lista de configuración.
///
/// Altura mínima 56 dp, objetivo táctil mínimo 48 dp.
/// Variante [destructive]: ícono y texto en [AppColors.error].
class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.trailing,
  });

  /// Ícono del ítem (24 dp).
  final IconData icon;

  /// Etiqueta del ítem.
  final String label;

  /// Callback al tocar el ítem.
  final VoidCallback onTap;

  /// Si es `true`, el ícono y el texto se muestran en color [AppColors.error].
  final bool destructive;

  /// Widget opcional a la derecha en lugar del chevron por defecto.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    final iconColor = destructive ? AppColors.error : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        color: AppColors.surface,
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 16, color: color)),
            ),
            trailing ?? Icon(Icons.chevron_right, size: 24, color: iconColor),
          ],
        ),
      ),
    );
  }
}
