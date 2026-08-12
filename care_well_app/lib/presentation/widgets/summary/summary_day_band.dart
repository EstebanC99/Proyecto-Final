import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'summary_generation_chip.dart';

/// Franja del día de la pantalla de Resumen (US 9.16).
///
/// Primera fila: la fecha en formato largo y, a la derecha, el chip "Generado …"
/// (solo si el backend informó el momento de generación). Segunda fila: el
/// estado de ánimo del día, a lo ancho de la franja.
///
/// El ánimo se lleva una fila entera a propósito: es texto redactado por la IA,
/// de largo impredecible, y compartiendo renglón con la fecha se truncaba.
class SummaryDayBand extends StatelessWidget {
  const SummaryDayBand({
    super.key,
    required this.fecha,
    this.estadoAnimo,
    this.generadoEn,
    this.delay = Duration.zero,
  });

  /// Día que resume la pantalla (normalmente hoy).
  final DateTime fecha;

  /// Estado de ánimo redactado por el resumen. `null` si no hubo registros.
  final String? estadoAnimo;

  /// Momento de generación del resumen. `null` si no se pudo determinar.
  final DateTime? generadoEn;

  final Duration delay;

  /// Fecha en formato "Sábado 8 de agosto". Reusa el mismo patrón que
  /// `DateGroupLabel`: inicializa el locale español y capitaliza la inicial.
  static String formatearFecha(DateTime fecha) {
    try {
      initializeDateFormatting('es');
      final texto = DateFormat("EEEE d 'de' MMMM", 'es').format(fecha);
      return texto.isEmpty
          ? texto
          : '${texto[0].toUpperCase()}${texto.substring(1)}';
    } catch (_) {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      delay: delay,
      from: 12,
      animate: !MediaQuery.disableAnimationsOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatearFecha(fecha),
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (generadoEn != null) ...[
                const SizedBox(width: AppSpacing.sm),
                // `Flexible` reparte el ancho en mitades con el `Expanded` de
                // la fecha, así que el chip necesita el `Align` para terminar
                // contra el borde derecho —el mismo de las cards— y no a mitad
                // de camino. El `Flexible` se mantiene como red: con la
                // tipografía del sistema muy grande el chip se comprime en
                // lugar de desbordar la fila.
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SummaryGenerationChip(generadoEn: generadoEn!),
                  ),
                ),
              ],
            ],
          ),
          if (estadoAnimo != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _MoodChip(estadoAnimo: estadoAnimo!),
          ],
        ],
      ),
    );
  }
}

/// Chip del estado de ánimo del día, a lo ancho de la franja y con los tokens
/// del módulo de ánimo (violeta) y no con el color primario de la app: así el
/// dato se lee como "estado de ánimo" en cualquier pantalla donde aparezca.
///
/// Al ocupar la fila completa el texto envuelve libremente: no lleva `maxLines`
/// ni `ellipsis`, porque no debe recortarse.
class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.estadoAnimo});

  final String estadoAnimo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: colors.moodContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.mood, size: 16, color: colors.moodAccent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              estadoAnimo,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: colors.moodAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
