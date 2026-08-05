import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../domain/global/tipos_evento_agenda_const.dart';

/// Tema visual (ícono y colores) asociado a un tipo de evento de agenda.
///
/// Mapea el id de catálogo del tipo ([TiposEventoAgendaConst]) a un ícono y a
/// un par de colores (acento + contenedor). Es un helper puramente
/// presentacional: no mantiene estado ni conoce el dominio más allá de los ids.
///
/// El tipo "Bienestar" reutiliza la paleta de Mi Salud
/// ([AppPalette.healthAccent]/[AppPalette.healthContainer]) para mantener
/// coherencia entre módulos.
abstract final class TipoEventoTheme {
  /// Ícono representativo del tipo con [id].
  static IconData iconFor(int id) => switch (id) {
    TiposEventoAgendaConst.citaMedica => Icons.local_hospital_outlined,
    TiposEventoAgendaConst.medicacion => Icons.medication_outlined,
    TiposEventoAgendaConst.rehabilitacion => Icons.accessibility_new_outlined,
    TiposEventoAgendaConst.control => Icons.monitor_heart_outlined,
    TiposEventoAgendaConst.hospitalizacion => Icons.king_bed_outlined,
    TiposEventoAgendaConst.cirugia => Icons.healing_outlined,
    TiposEventoAgendaConst.tratamiento => Icons.medical_services_outlined,
    TiposEventoAgendaConst.bienestar => Icons.spa_outlined,
    TiposEventoAgendaConst.sintoma => Icons.sick_outlined,
    TiposEventoAgendaConst.diagnostico => Icons.assignment_outlined,
    TiposEventoAgendaConst.vacuna => Icons.vaccines_outlined,
    TiposEventoAgendaConst.actividadFisica => Icons.directions_run_outlined,
    _ => Icons.event_outlined,
  };

  /// Color de acento (ícono/texto destacado) del tipo con [id].
  static Color accentFor(BuildContext context, int id) => switch (id) {
    TiposEventoAgendaConst.citaMedica => context.colors.info,
    TiposEventoAgendaConst.medicacion => context.colors.secondary,
    TiposEventoAgendaConst.rehabilitacion => context.colors.primary,
    TiposEventoAgendaConst.control => context.colors.primary,
    TiposEventoAgendaConst.hospitalizacion => context.colors.error,
    TiposEventoAgendaConst.cirugia => context.colors.error,
    TiposEventoAgendaConst.tratamiento => context.colors.info,
    TiposEventoAgendaConst.bienestar => context.colors.healthAccent,
    TiposEventoAgendaConst.sintoma => context.colors.warning,
    TiposEventoAgendaConst.diagnostico => context.colors.info,
    TiposEventoAgendaConst.vacuna => context.colors.success,
    TiposEventoAgendaConst.actividadFisica => context.colors.habitsAccent,
    _ => context.colors.textSecondary,
  };

  /// Color de contenedor (fondo suave) del tipo con [id].
  static Color containerFor(BuildContext context, int id) => switch (id) {
    TiposEventoAgendaConst.citaMedica => context.colors.infoContainer,
    TiposEventoAgendaConst.medicacion => context.colors.secondaryContainer,
    TiposEventoAgendaConst.rehabilitacion => context.colors.primaryContainer,
    TiposEventoAgendaConst.control => context.colors.primaryContainer,
    TiposEventoAgendaConst.hospitalizacion => context.colors.errorContainer,
    TiposEventoAgendaConst.cirugia => context.colors.errorContainer,
    TiposEventoAgendaConst.tratamiento => context.colors.infoContainer,
    TiposEventoAgendaConst.bienestar => context.colors.healthContainer,
    TiposEventoAgendaConst.sintoma => context.colors.warningContainer,
    TiposEventoAgendaConst.diagnostico => context.colors.infoContainer,
    TiposEventoAgendaConst.vacuna => context.colors.successContainer,
    TiposEventoAgendaConst.actividadFisica => context.colors.habitsContainer,
    _ => context.colors.surfaceVariant,
  };
}
