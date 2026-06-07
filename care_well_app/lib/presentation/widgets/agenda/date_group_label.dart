import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';

/// Encabezado de grupo de eventos por fecha.
///
/// Muestra "HOY", "MAÑANA" o la fecha en formato "lunes 10 de junio".
class DateGroupLabel extends StatelessWidget {
  const DateGroupLabel({super.key, required this.fecha});

  final DateTime fecha;

  static final _meses = [
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

  static final _dias = [
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final day = DateTime(fecha.year, fecha.month, fecha.day);

    if (day == today) return 'HOY';
    if (day == tomorrow) return 'MAÑANA';

    // Intentar usar intl con locale español; si no está inicializado, usar fallback manual.
    try {
      initializeDateFormatting('es');
      return DateFormat("EEEE d 'de' MMMM", 'es').format(fecha);
    } catch (_) {
      final diaSemana = _dias[fecha.weekday - 1];
      final mes = _meses[fecha.month - 1];
      return '$diaSemana ${fecha.day} de $mes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        _label().toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
