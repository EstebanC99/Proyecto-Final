import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'notification_status_chip.dart';
import 'tipo_evento_theme.dart';

/// Card de una ocurrencia de evento de agenda.
///
/// Muestra la hora de inicio, un ícono coloreado según el tipo de evento, el
/// título, la descripción del tipo y, cuando la ocurrencia es futura, el chip
/// de recordatorio. Las ocurrencias ya iniciadas ([OcurrenciaEventoAgenda.esEditable]
/// `== false`) se atenúan y muestran un candado.
///
/// Es puramente presentacional: la lógica de acciones la resuelve el contenedor
/// mediante [onTap].
class OcurrenciaCard extends StatelessWidget {
  const OcurrenciaCard({super.key, required this.ocurrencia, this.onTap});

  final OcurrenciaEventoAgenda ocurrencia;

  /// Callback al tocar la card. Si es `null`, la card no es interactiva.
  final VoidCallback? onTap;

  String _formatHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final editable = ocurrencia.esEditable();
    final tipoId = ocurrencia.tipo.id;
    final accent = editable
        ? TipoEventoTheme.accentFor(tipoId)
        : AppColors.textDisabled;
    final container = editable
        ? TipoEventoTheme.containerFor(tipoId)
        : AppColors.surfaceVariant;
    final tieneRecordatorio =
        ocurrencia.minutosAnticipacionRecordatorio != null;

    final card = Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppSpacing.elev1,
        border: editable
            ? null
            : Border.all(color: AppColors.outline, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícono de tipo sobre contenedor coloreado
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: container,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  TipoEventoTheme.iconFor(tipoId),
                  size: 22,
                  color: accent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _formatHora(ocurrencia.fechaHoraInicio),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: editable ? accent : AppColors.textDisabled,
                          ),
                        ),
                        if (ocurrencia.esRecurrente) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.repeat_rounded,
                            size: 14,
                            color: editable
                                ? AppColors.textSecondary
                                : AppColors.textDisabled,
                          ),
                        ],
                        const Spacer(),
                        if (!editable)
                          const Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: AppColors.textDisabled,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ocurrencia.titulo,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: editable
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ocurrencia.tipo.descripcion,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (ocurrencia.descripcion != null &&
                        ocurrencia.descripcion!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        ocurrencia.descripcion!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (editable) ...[
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

    return editable ? card : Opacity(opacity: 0.6, child: card);
  }
}
