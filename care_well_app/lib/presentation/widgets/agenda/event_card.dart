import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'notification_status_chip.dart';

/// Card de un evento de agenda.
///
/// Si el evento está vencido ([EventoAgenda.estaVencido]), aplica opacidad
/// reducida y muestra un ícono de candado. Solo muestra [NotificationStatusChip]
/// cuando el evento es futuro.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.evento,
    required this.tieneRecordatorio,
    required this.onTap,
  });

  final EventoAgenda evento;
  final bool tieneRecordatorio;
  final VoidCallback onTap;

  String _formatHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _labelTipo(TipoEventoAgenda tipo) {
    switch (tipo.id) {
      case TiposEventoAgendaConst.citaMedica:
        return 'Cita médica';
      case TiposEventoAgendaConst.medicacion:
        return 'Medicación';
      case TiposEventoAgendaConst.rehabilitacion:
        return 'Rehabilitación';
      case TiposEventoAgendaConst.control:
        return 'Control';
      default:
        return 'Otro';
    }
  }

  IconData _iconTipo(TipoEventoAgenda tipo) {
    switch (tipo.id) {
      case TiposEventoAgendaConst.citaMedica:
        return Icons.local_hospital_outlined;
      case TiposEventoAgendaConst.medicacion:
        return Icons.medication_outlined;
      case TiposEventoAgendaConst.rehabilitacion:
        return Icons.accessibility_new_outlined;
      case TiposEventoAgendaConst.control:
        return Icons.monitor_heart_outlined;
      default:
        return Icons.event_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vencido = evento.estaVencido();

    final card = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppSpacing.elev1,
        border: vencido ? Border.all(color: AppColors.outline, width: 1) : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hora e ícono de tipo
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _formatHora(evento.fechaHoraInicio),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: vencido ? AppColors.textDisabled : AppColors.info,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    _iconTipo(evento.tipo),
                    size: 18,
                    color: vencido ? AppColors.textDisabled : AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            evento.titulo,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: vencido
                                  ? AppColors.textDisabled
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (vencido)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: AppColors.textDisabled,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _labelTipo(evento.tipo),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (evento.descripcion != null &&
                        evento.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        evento.descripcion!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (!vencido) ...[
                      const SizedBox(height: 8),
                      NotificationStatusChip(activo: tieneRecordatorio),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (vencido) {
      return Opacity(opacity: 0.55, child: card);
    }
    return card;
  }
}
