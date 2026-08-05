import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'health_timeline_style.dart';

/// Fila de la línea de tiempo para un [EventoBase].
///
/// Muestra un dot circular del color de la categoría del evento y una línea
/// conectora vertical (excepto para el último elemento). A la derecha, una
/// tarjeta de solo lectura con categoría, fecha y descripción truncada.
class HealthTimelineTile extends StatelessWidget {
  const HealthTimelineTile({
    super.key,
    required this.evento,
    required this.isLast,
  });

  final EventoBase evento;

  /// Si es el último elemento, no se renderiza la línea conectora.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = categoriaEventoColor(context, evento.categoriaEvento);
    final label = categoriaEventoLabel(evento.categoriaEvento);
    final fechaStr = DateFormat(
      'd MMM · HH:mm',
      'es',
    ).format(evento.fechaHora.toLocal());

    return Semantics(
      label: '$label: ${evento.descripcion}, $fechaStr',
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
                          color: context.colors.surfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Columna derecha: tarjeta (solo lectura, sin acción)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    boxShadow: AppSpacing.elev1,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chip de categoría
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
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colors.textDisabled,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Título / descripción truncada
                      Text(
                        evento.descripcion,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: context.colors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
