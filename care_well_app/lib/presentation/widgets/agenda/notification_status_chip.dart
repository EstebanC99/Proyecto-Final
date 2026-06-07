import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Chip pequeño que indica si un evento tiene recordatorio programado.
///
/// Cuando [activo] es `true`, muestra fondo azul claro con texto "Con recordatorio".
/// Cuando es `false`, muestra `surfaceVariant` con texto "Sin recordatorio".
class NotificationStatusChip extends StatelessWidget {
  const NotificationStatusChip({super.key, required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: activo ? AppColors.infoContainer : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 12,
            color: activo ? AppColors.info : AppColors.textDisabled,
          ),
          const SizedBox(width: 4),
          Text(
            activo ? 'Con recordatorio' : 'Sin recordatorio',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: activo ? AppColors.info : AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
