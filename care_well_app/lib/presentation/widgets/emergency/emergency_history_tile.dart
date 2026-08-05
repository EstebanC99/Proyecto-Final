import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Fila del historial corto de emergencias.
///
/// Muestra cuándo se activó y quién la activó. Es un registro inmutable: no
/// tiene acciones ni navegación.
///
/// Va en color neutro y con ícono de historial, no en `emergencyRed`: esto ya
/// pasó, no está pasando. El rojo queda reservado para el botón, que es lo
/// único que debe llamar la atención en la pantalla.
class EmergencyHistoryTile extends StatelessWidget {
  const EmergencyHistoryTile({super.key, required this.emergencia});

  final Emergencia emergencia;

  @override
  Widget build(BuildContext context) {
    final fechaHora = emergencia.fechaHora.toLocal();
    final fecha = DateFormat('d MMM yyyy', 'es').format(fechaHora);
    final hora = DateFormat('HH:mm').format(fechaHora);

    final activador =
        '${emergencia.activador.nombre} ${emergencia.activador.apellido}';
    final descripcion = emergencia.descripcion;

    return Semantics(
      label: 'Emergencia del $fecha a las $hora, activada por $activador',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.history,
                size: 16,
                color: context.colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$fecha · $hora',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    Text(
                      'Activada por $activador',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    // Hoy la descripción siempre viaja nula (no hay input al
                    // activar), pero el campo existe en el contrato.
                    if (descripcion != null && descripcion.isNotEmpty)
                      Text(
                        descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
