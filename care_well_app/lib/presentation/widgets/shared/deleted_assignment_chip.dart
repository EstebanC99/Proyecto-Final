import 'package:flutter/material.dart';

import '../../../config/constraints/business_rules.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Construye el texto de countdown hasta la baja definitiva de una asignación
/// eliminada, a partir de [fechaEliminacion].
///
/// El vencimiento es `fechaEliminacion + AppBusinessRules.diasGraciaReactivacion`.
String reactivacionCountdownLabel(DateTime? fechaEliminacion) {
  if (fechaEliminacion == null) return 'Eliminada';
  final vencimiento = fechaEliminacion.add(
    const Duration(days: AppBusinessRules.diasGraciaReactivacion),
  );
  final restante = vencimiento.difference(DateTime.now());
  if (restante.inSeconds <= 0) return 'Vencido';
  final dias = restante.inDays;
  if (dias == 0) return 'Vence hoy';
  if (dias == 1) return 'Vence en 1 día';
  return 'Vence en $dias días';
}

/// Chip gris neutro para asignaciones eliminadas (estado inactivo).
/// Renderiza el countdown de reactivación.
class DeletedAssignmentChip extends StatelessWidget {
  const DeletedAssignmentChip({super.key, this.fechaEliminacion, this.label})
    : assert(
        fechaEliminacion != null || label != null,
        'Pasá fechaEliminacion o label.',
      );

  final DateTime? fechaEliminacion;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final texto = label ?? reactivacionCountdownLabel(fechaEliminacion);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.outline, width: 1),
      ),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
