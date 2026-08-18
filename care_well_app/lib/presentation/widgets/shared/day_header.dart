import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'date_labels.dart';

/// Encabezado del día seleccionado en una vista de tira semanal.
///
/// Muestra un rótulo relativo ("HOY", "MAÑANA" o el día de la semana) y, al
/// lado, la fecha larga y la cantidad de eventos. No es interactivo. Lo usan
/// tanto la agenda como los eventos de salud.
class DayHeader extends StatelessWidget {
  const DayHeader({
    super.key,
    required this.dia,
    required this.cantidadEventos,
    this.hoy,
  });

  /// Día que se está mostrando.
  final DateTime dia;

  /// Cantidad de eventos del día.
  final int cantidadEventos;

  /// Fecha considerada "hoy". Inyectable para tests.
  final DateTime? hoy;

  @override
  Widget build(BuildContext context) {
    final diaTruncado = DateTime(dia.year, dia.month, dia.day);

    final rotulo = rotuloRelativoDia(diaTruncado, hoy: hoy);
    final fechaLarga =
        '${nombresDia[diaTruncado.weekday - 1]} ${diaTruncado.day} '
        'de ${nombresMes[diaTruncado.month - 1]}';
    final eventos = cantidadEventos == 1
        ? '1 evento'
        : '$cantidadEventos eventos';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            rotulo.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$fechaLarga · $eventos',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
