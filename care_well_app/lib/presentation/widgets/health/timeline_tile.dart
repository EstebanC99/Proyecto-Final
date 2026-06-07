import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'health_event_card.dart';

/// Fila de la línea de tiempo para un [EventoDeSalud].
///
/// Muestra un dot circular del color del tipo de evento y una línea conectora
/// vertical (excepto para el último elemento). A la derecha, una tarjeta con
/// tipo, fecha y descripción truncada.
class TimelineTile extends StatelessWidget {
  const TimelineTile({
    super.key,
    required this.evento,
    required this.isLast,
    required this.onTap,
  });

  final EventoDeSalud evento;

  /// Si es el último elemento, no se renderiza la línea conectora.
  final bool isLast;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = healthEventColor(evento.tipo);
    final label = healthEventLabel(evento.tipo);
    final fechaStr = DateFormat('MMM yyyy', 'es').format(evento.fecha);

    return Semantics(
      label: 'Evento: ${evento.descripcion}, $fechaStr, tipo $label',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Columna izquierda: dot + línea
            SizedBox(
              width: 36,
              child: Column(
                children: [
                  // Dot
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Línea conectora (salvo último)
                  if (!isLast)
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 2,
                          color: AppColors.surfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Columna derecha: tarjeta
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      boxShadow: AppSpacing.elev1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 4),
                        // Fecha
                        Text(
                          fechaStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Título / descripción truncada
                        Text(
                          evento.descripcion,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
