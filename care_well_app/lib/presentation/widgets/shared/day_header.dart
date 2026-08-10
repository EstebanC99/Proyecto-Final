import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

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

  static const _nombresDia = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  static const _nombresMes = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// Rótulo relativo del día ("Hoy", "Mañana", "Ayer" o el día de la semana).
  String _rotulo(DateTime hoyTruncado, DateTime diaTruncado) {
    final diferencia = diaTruncado.difference(hoyTruncado).inDays;
    return switch (diferencia) {
      0 => 'Hoy',
      1 => 'Mañana',
      -1 => 'Ayer',
      _ => _nombresDia[diaTruncado.weekday - 1],
    };
  }

  @override
  Widget build(BuildContext context) {
    final ahora = hoy ?? DateTime.now();
    final hoyTruncado = DateTime(ahora.year, ahora.month, ahora.day);
    final diaTruncado = DateTime(dia.year, dia.month, dia.day);

    final rotulo = _rotulo(hoyTruncado, diaTruncado);
    final fechaLarga =
        '${_nombresDia[diaTruncado.weekday - 1]} ${diaTruncado.day} '
        'de ${_nombresMes[diaTruncado.month - 1]}';
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
