import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Encabezado de grupo por día para la lista de eventos de salud.
///
/// Análogo a [_DayGroupHeader] de la agenda, pero expuesto como widget
/// público del módulo de salud. Muestra "HOY" en [AppColors.healthAccent],
/// "MAÑANA" en [AppColors.textSecondary], o el nombre completo del día.
/// Es colapsable: cuando está cerrado muestra el contador de eventos.
class HealthEventDayGroupHeader extends StatelessWidget {
  const HealthEventDayGroupHeader({
    super.key,
    required this.fecha,
    required this.count,
    required this.expanded,
    required this.onTap,
  });

  final DateTime fecha;
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  static const _meses = [
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

  static const _diasSemana = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  bool get _esHoy {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(fecha.year, fecha.month, fecha.day) == today;
  }

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final day = DateTime(fecha.year, fecha.month, fecha.day);
    if (day == today) return 'HOY';
    if (day == tomorrow) return 'MAÑANA';
    return '${_diasSemana[fecha.weekday - 1]} ${fecha.day} de ${_meses[fecha.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = _esHoy
        ? AppColors.healthAccent
        : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _label().toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: labelColor,
                ),
              ),
            ),
            if (!expanded) ...[
              Text(
                '$count ${count == 1 ? "evento" : "eventos"}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              expanded
                  ? Icons.expand_more_rounded
                  : Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
