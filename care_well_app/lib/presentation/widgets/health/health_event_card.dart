import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Retorna el ícono correspondiente al tipo de evento de salud.
IconData _iconForTipo(TipoEventoSalud tipo) {
  switch (tipo) {
    case TipoEventoSalud.citaMedica:
      return Icons.medical_services_outlined;
    case TipoEventoSalud.hospitalizacion:
      return Icons.local_hospital_outlined;
    case TipoEventoSalud.medicacion:
      return Icons.medication_outlined;
    case TipoEventoSalud.cirugia:
      return Icons.biotech_outlined;
    case TipoEventoSalud.tratamiento:
      return Icons.healing_outlined;
    case TipoEventoSalud.bienestar:
      return Icons.favorite_outline;
    case TipoEventoSalud.sintoma:
      return Icons.sick_outlined;
    case TipoEventoSalud.diagnostico:
      return Icons.search_outlined;
    case TipoEventoSalud.vacuna:
      return Icons.vaccines_outlined;
    case TipoEventoSalud.otro:
      return Icons.event_note_outlined;
  }
}

/// Retorna el color de acento correspondiente al tipo de evento de salud.
Color _colorForTipo(TipoEventoSalud tipo) {
  switch (tipo) {
    case TipoEventoSalud.citaMedica:
      return AppColors.healthAccent;
    case TipoEventoSalud.hospitalizacion:
      return AppColors.error;
    case TipoEventoSalud.medicacion:
      return const Color(0xFF2563EB);
    case TipoEventoSalud.cirugia:
      return AppColors.error;
    case TipoEventoSalud.tratamiento:
      return AppColors.moodAccent;
    case TipoEventoSalud.bienestar:
      return AppColors.success;
    case TipoEventoSalud.sintoma:
      return AppColors.habitsAccent;
    case TipoEventoSalud.diagnostico:
      return const Color(0xFF0284C7);
    case TipoEventoSalud.vacuna:
      return const Color(0xFF059669);
    case TipoEventoSalud.otro:
      return AppColors.textSecondary;
  }
}

/// Etiqueta legible del tipo de evento.
String _labelForTipo(TipoEventoSalud tipo) {
  switch (tipo) {
    case TipoEventoSalud.citaMedica:
      return 'Cita médica';
    case TipoEventoSalud.hospitalizacion:
      return 'Hospitalización';
    case TipoEventoSalud.medicacion:
      return 'Medicación';
    case TipoEventoSalud.cirugia:
      return 'Cirugía';
    case TipoEventoSalud.tratamiento:
      return 'Tratamiento';
    case TipoEventoSalud.bienestar:
      return 'Bienestar';
    case TipoEventoSalud.sintoma:
      return 'Síntoma';
    case TipoEventoSalud.diagnostico:
      return 'Diagnóstico';
    case TipoEventoSalud.vacuna:
      return 'Vacuna';
    case TipoEventoSalud.otro:
      return 'Otro';
  }
}

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
