import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';
import 'mood_picker.dart';

/// Gráfico de barras de los últimos 7 días de estados de ánimo.
///
/// Renderizado con Containers de Flutter sin dependencias externas de charting.
/// Las barras tienen altura proporcional al nivel (1-5), coloreadas según nivel.
class MoodBarChart extends StatelessWidget {
  const MoodBarChart({super.key, required this.estados});

  final List<EstadoDeAnimo> estados;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });

    // Nivel promedio por día (puede haber varios registros en el mismo día).
    final Map<DateTime, double> levelByDay = {};
    for (final day in days) {
      final delDia = estados.where((e) {
        final ed = e.fecha;
        return ed.year == day.year &&
            ed.month == day.month &&
            ed.day == day.day;
      }).toList();
      if (delDia.isNotEmpty) {
        final suma = delDia.fold<int>(
          0,
          (acc, e) => acc + _enumToLevel(e.estado),
        );
        levelByDay[day] = suma / delDia.length;
      }
    }

    final hasDatos = levelByDay.isNotEmpty;

    return Column(
      children: [
        if (!hasDatos)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Sin registros esta semana',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              final level = levelByDay[day];
              final barHeight = level != null ? (level / 5) * 80 : 0.0;
              final color = level != null
                  ? moodLevelColor(level.round())
                  : AppColors.surfaceVariant;
              final dayLabel = DateFormat(
                'E',
                'es',
              ).format(day)[0].toUpperCase();

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Barra
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    width: 28,
                    height: barHeight > 0 ? barHeight : 4,
                    decoration: BoxDecoration(
                      color: barHeight > 0 ? color : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Etiqueta de día
                  Text(
                    dayLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  int _enumToLevel(EstadoAnimoEnum estado) {
    switch (estado) {
      case EstadoAnimoEnum.muyMal:
        return 1;
      case EstadoAnimoEnum.mal:
        return 2;
      case EstadoAnimoEnum.regular:
        return 3;
      case EstadoAnimoEnum.bien:
        return 4;
      case EstadoAnimoEnum.muyBien:
        return 5;
    }
  }
}
