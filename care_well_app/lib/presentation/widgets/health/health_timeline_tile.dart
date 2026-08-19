import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'health_timeline_style.dart';

/// Fila de la línea de tiempo para un [EventoBase].
///
/// Va dentro de la tarjeta del día, así que no dibuja fondo ni sombra propios:
/// aporta una marca de categoría a la izquierda, la descripción y la categoría
/// en el medio, y la hora a la derecha.
///
/// La marca es un cuadrado del tono contenedor de la categoría con un punto del
/// acento adentro, sin ícono: `EventoBase` no trae el tipo concreto del
/// registro, sólo su categoría, y no se le va a pedir al backend un campo nuevo
/// por una decisión visual.
class HealthTimelineTile extends StatelessWidget {
  const HealthTimelineTile({super.key, required this.evento});

  final EventoBase evento;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = categoriaEventoColor(context, evento.categoriaEvento);
    final fondo = categoriaEventoContainer(context, evento.categoriaEvento);
    final label = categoriaEventoLabel(evento.categoriaEvento);
    final local = evento.fechaHora.toLocal();
    final hora = DateFormat('HH:mm').format(local);

    return Semantics(
      label: '$label: ${evento.descripcion}, $hora',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            // Cuadrado fijo: contiene un punto, no texto, así que no necesita
            // crecer con la escala tipográfica.
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    evento.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              hora,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.textSecondary,
                // Ancho de dígito uniforme: las horas de la columna quedan
                // alineadas entre filas.
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
