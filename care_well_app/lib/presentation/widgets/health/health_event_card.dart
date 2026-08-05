import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Retorna el ícono correspondiente al tipo de evento de salud.
///
/// Los ids provienen del catálogo compartido de tipos de evento
/// ([TiposEventoAgendaConst]).
IconData _iconForTipo(TipoEventoSalud tipo) {
  switch (tipo.id) {
    case TiposEventoAgendaConst.citaMedica:
      return Icons.medical_services_outlined;
    case TiposEventoAgendaConst.control:
      return Icons.monitor_heart_outlined;
    case TiposEventoAgendaConst.hospitalizacion:
      return Icons.local_hospital_outlined;
    case TiposEventoAgendaConst.medicacion:
      return Icons.medication_outlined;
    case TiposEventoAgendaConst.cirugia:
      return Icons.biotech_outlined;
    case TiposEventoAgendaConst.tratamiento:
      return Icons.healing_outlined;
    case TiposEventoAgendaConst.rehabilitacion:
      return Icons.accessibility_new_outlined;
    case TiposEventoAgendaConst.bienestar:
      return Icons.favorite_outline;
    case TiposEventoAgendaConst.sintoma:
      return Icons.sick_outlined;
    case TiposEventoAgendaConst.diagnostico:
      return Icons.search_outlined;
    case TiposEventoAgendaConst.vacuna:
      return Icons.vaccines_outlined;
    case TiposEventoAgendaConst.actividadFisica:
      return Icons.directions_run_outlined;
    default:
      return Icons.event_note_outlined;
  }
}

/// Retorna el color de acento correspondiente al tipo de evento de salud.
Color _colorForTipo(BuildContext context, TipoEventoSalud tipo) {
  switch (tipo.id) {
    case TiposEventoAgendaConst.citaMedica:
    case TiposEventoAgendaConst.control:
      return context.colors.healthAccent;
    case TiposEventoAgendaConst.hospitalizacion:
    case TiposEventoAgendaConst.cirugia:
      return context.colors.error;
    case TiposEventoAgendaConst.medicacion:
      return const Color(0xFF2563EB);
    case TiposEventoAgendaConst.tratamiento:
    case TiposEventoAgendaConst.rehabilitacion:
      return context.colors.moodAccent;
    case TiposEventoAgendaConst.bienestar:
      return context.colors.success;
    case TiposEventoAgendaConst.sintoma:
    case TiposEventoAgendaConst.actividadFisica:
      return context.colors.habitsAccent;
    case TiposEventoAgendaConst.diagnostico:
      return const Color(0xFF0284C7);
    case TiposEventoAgendaConst.vacuna:
      return const Color(0xFF059669);
    default:
      return context.colors.textSecondary;
  }
}

/// Etiqueta legible del tipo de evento.
String _labelForTipo(TipoEventoSalud tipo) => tipo.descripcion;

/// Funciones públicas para uso en otros widgets del módulo salud.
IconData healthEventIcon(TipoEventoSalud tipo) => _iconForTipo(tipo);
Color healthEventColor(BuildContext context, TipoEventoSalud tipo) =>
    _colorForTipo(context, tipo);
String healthEventLabel(TipoEventoSalud tipo) => _labelForTipo(tipo);

/// Card de un [EventoSalud] para la lista mensual y la línea de tiempo.
///
/// Parámetros:
/// - [tieneNotas]: muestra un indicador discreto cuando el evento tiene notas.
/// - [mostrarFecha]: cuando es `true` muestra "d MMM · HH:mm"; cuando es
///   `false` (dentro de un grupo por día) muestra solo la hora.
class HealthEventCard extends StatelessWidget {
  const HealthEventCard({
    super.key,
    required this.evento,
    required this.onTap,
    this.tieneNotas = false,
    this.mostrarFecha = true,
  });

  final EventoSalud evento;
  final VoidCallback onTap;

  /// Si es `true`, muestra un pequeño indicador de notas bajo la descripción.
  final bool tieneNotas;

  /// Si es `false`, muestra solo la hora (útil dentro de grupos por día).
  final bool mostrarFecha;

  @override
  Widget build(BuildContext context) {
    final color = _colorForTipo(context, evento.tipo);
    final label = _labelForTipo(evento.tipo);
    final icon = _iconForTipo(evento.tipo);
    final fechaHora = evento.fechaHora.toLocal();
    final horaStr = DateFormat('HH:mm').format(fechaHora);
    final fechaStr = mostrarFecha
        ? '${DateFormat('d MMM', 'es').format(fechaHora)} · $horaStr'
        : horaStr;
    final desdeAgenda = evento.fechaOcurrenciaEventoAgenda != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.surface,
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
                      const Spacer(),
                      Text(
                        fechaStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Descripción truncada
                  Text(
                    evento.descripcion,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Indicadores (notas / origen agenda)
                  if (tieneNotas || desdeAgenda) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (desdeAgenda) ...[
                          Icon(
                            Icons.event_available_outlined,
                            size: 11,
                            color: context.colors.textDisabled,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Desde agenda',
                            style: TextStyle(
                              fontSize: 10,
                              color: context.colors.textDisabled,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (tieneNotas) const SizedBox(width: 10),
                        ],
                        if (tieneNotas) ...[
                          Icon(
                            Icons.comment_outlined,
                            size: 11,
                            color: color.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Con notas',
                            style: TextStyle(
                              fontSize: 10,
                              color: color.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: context.colors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
