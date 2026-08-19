import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../shared/date_labels.dart';

/// Encabezado de un día en la línea de tiempo de salud.
///
/// Chip con el número y la abreviatura del día, y al lado el rótulo relativo
/// ("Hoy", "Ayer" o el nombre del día) con la cantidad de registros.
///
/// El día de hoy se distingue con el color del chip, pero el rótulo ya dice
/// "Hoy": la información no queda librada al color.
///
/// No reutiliza `DayHeader` (el de la tira semanal): ese resuelve otro layout,
/// con la fecha larga en la misma línea y sin chip.
class DayGroupHeader extends StatelessWidget {
  const DayGroupHeader({
    super.key,
    required this.dia,
    required this.cantidad,
    this.hoy,
  });

  /// Día del grupo, truncado a año-mes-día.
  final DateTime dia;

  /// Cantidad de registros de ese día.
  final int cantidad;

  /// Fecha considerada "hoy". Inyectable para tests.
  final DateTime? hoy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ahora = hoy ?? DateTime.now();
    final esHoy =
        dia.year == ahora.year &&
        dia.month == ahora.month &&
        dia.day == ahora.day;

    final rotulo = rotuloRelativoDia(dia, hoy: hoy);
    final registros = cantidad == 1 ? '1 registro' : '$cantidad registros';

    return Row(
      children: [
        _ChipDia(dia: dia, esHoy: esHoy),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // El rótulo relativo devuelve el nombre del día en minúsculas.
                rotulo[0].toUpperCase() + rotulo.substring(1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                registros,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Cuadrado con el número del día y su abreviatura.
class _ChipDia extends StatelessWidget {
  const _ChipDia({required this.dia, required this.esHoy});

  final DateTime dia;
  final bool esHoy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textoNumero = esHoy ? colors.onPrimary : colors.textPrimary;
    final textoDia = esHoy ? colors.onPrimary : colors.textSecondary;

    // El chip acota la escala tipográfica en vez de fijar su tamaño: a escala
    // completa el número y la abreviatura no entran en 38dp, y recortarlos
    // dejaría el día ilegible. El resto de la pantalla sí escala libre.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: esHoy ? colors.primary : colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: esHoy ? colors.primary : colors.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${dia.day}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: textoNumero,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                nombresDiaCorto[dia.weekday - 1].toUpperCase(),
                style: TextStyle(
                  fontSize: 8.5,
                  height: 1,
                  letterSpacing: 0.4,
                  color: textoDia,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
