import 'package:flutter/material.dart';

import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'health_event_card.dart';

/// Chip presentacional del tipo de evento de salud.
///
/// Muestra ícono + etiqueta con el color semántico del tipo.
/// Reutiliza [healthEventColor], [healthEventLabel] y [healthEventIcon]
/// del módulo para mantener coherencia con la [HealthEventCard].
///
/// Uso principal: header del [HealthEventDetailScreen].
class HealthEventTypeChip extends StatelessWidget {
  const HealthEventTypeChip({super.key, required this.tipo});

  final TipoEventoSalud tipo;

  @override
  Widget build(BuildContext context) {
    final color = healthEventColor(tipo);
    final label = healthEventLabel(tipo);
    final icon = healthEventIcon(tipo);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
