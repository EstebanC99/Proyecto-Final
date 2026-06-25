import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Retorna el ícono correspondiente al tipo de evento de salud.
IconData _iconForTipo(TipoEventoSalud tipo) {
  switch (tipo.id) {
    case TiposEventoSaludConst.citaMedica:
      return Icons.medical_services_outlined;
    case TiposEventoSaludConst.hospitalizacion:
      return Icons.local_hospital_outlined;
    case TiposEventoSaludConst.medicacion:
      return Icons.medication_outlined;
    case TiposEventoSaludConst.cirugia:
      return Icons.biotech_outlined;
    case TiposEventoSaludConst.tratamiento:
      return Icons.healing_outlined;
    case TiposEventoSaludConst.bienestar:
      return Icons.favorite_outline;
    case TiposEventoSaludConst.sintoma:
      return Icons.sick_outlined;
    case TiposEventoSaludConst.diagnostico:
      return Icons.search_outlined;
    case TiposEventoSaludConst.vacuna:
      return Icons.vaccines_outlined;
    default:
      return Icons.event_note_outlined;
  }
}

/// Retorna el color de acento correspondiente al tipo de evento de salud.
Color _colorForTipo(TipoEventoSalud tipo) {
  switch (tipo.id) {
    case TiposEventoSaludConst.citaMedica:
      return AppColors.healthAccent;
    case TiposEventoSaludConst.hospitalizacion:
      return AppColors.error;
    case TiposEventoSaludConst.medicacion:
      return const Color(0xFF2563EB);
    case TiposEventoSaludConst.cirugia:
      return AppColors.error;
    case TiposEventoSaludConst.tratamiento:
      return AppColors.moodAccent;
    case TiposEventoSaludConst.bienestar:
      return AppColors.success;
    case TiposEventoSaludConst.sintoma:
      return AppColors.habitsAccent;
    case TiposEventoSaludConst.diagnostico:
      return const Color(0xFF0284C7);
    case TiposEventoSaludConst.vacuna:
      return const Color(0xFF059669);
    default:
      return AppColors.textSecondary;
  }
}

/// Etiqueta legible del tipo de evento.
String _labelForTipo(TipoEventoSalud tipo) => tipo.descripcion;

/// Funciones públicas para uso en otros widgets del módulo salud.
IconData healthEventIcon(TipoEventoSalud tipo) => _iconForTipo(tipo);
Color healthEventColor(TipoEventoSalud tipo) => _colorForTipo(tipo);
String healthEventLabel(TipoEventoSalud tipo) => _labelForTipo(tipo);

/// Card de un [EventoDeSalud] para la lista y la línea de tiempo.
class HealthEventCard extends StatelessWidget {
  const HealthEventCard({super.key, required this.evento, required this.onTap});

  final EventoDeSalud evento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _colorForTipo(evento.tipo);
    final label = _labelForTipo(evento.tipo);
    final icon = _iconForTipo(evento.tipo);
    final fechaStr = DateFormat('d MMM yyyy', 'es').format(evento.fecha);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: AppSpacing.elev1,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono del tipo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: AppSpacing.md),
            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Chip de tipo
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                      // Fecha
                      Text(
                        fechaStr,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Descripción truncada
                  Text(
                    evento.descripcion,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
