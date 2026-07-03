import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../domain/global/tipos_evento_agenda_const.dart';

/// Tema visual (ícono y colores) asociado a un tipo de evento de agenda.
///
/// Mapea el id de catálogo del tipo ([TiposEventoAgendaConst]) a un ícono y a
/// un par de colores (acento + contenedor). Es un helper puramente
/// presentacional: no mantiene estado ni conoce el dominio más allá de los ids.
///
/// El tipo "Bienestar" reutiliza la paleta de Mi Salud
/// ([AppColors.healthAccent]/[AppColors.healthContainer]) para mantener
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
  static Color accentFor(int id) => switch (id) {
    TiposEventoAgendaConst.citaMedica => AppColors.info,
    TiposEventoAgendaConst.medicacion => AppColors.secondary,
    TiposEventoAgendaConst.rehabilitacion => AppColors.primary,
    TiposEventoAgendaConst.control => AppColors.primary,
    TiposEventoAgendaConst.hospitalizacion => AppColors.error,
    TiposEventoAgendaConst.cirugia => AppColors.error,
    TiposEventoAgendaConst.tratamiento => AppColors.info,
    TiposEventoAgendaConst.bienestar => AppColors.healthAccent,
    TiposEventoAgendaConst.sintoma => AppColors.warning,
    TiposEventoAgendaConst.diagnostico => AppColors.info,
    TiposEventoAgendaConst.vacuna => AppColors.success,
    TiposEventoAgendaConst.actividadFisica => AppColors.habitsAccent,
    _ => AppColors.textSecondary,
  };

  /// Color de contenedor (fondo suave) del tipo con [id].
  static Color containerFor(int id) => switch (id) {
    TiposEventoAgendaConst.citaMedica => AppColors.infoContainer,
    TiposEventoAgendaConst.medicacion => AppColors.secondaryContainer,
    TiposEventoAgendaConst.rehabilitacion => AppColors.primaryContainer,
    TiposEventoAgendaConst.control => AppColors.primaryContainer,
    TiposEventoAgendaConst.hospitalizacion => AppColors.errorContainer,
    TiposEventoAgendaConst.cirugia => AppColors.errorContainer,
    TiposEventoAgendaConst.tratamiento => AppColors.infoContainer,
    TiposEventoAgendaConst.bienestar => AppColors.healthContainer,
    TiposEventoAgendaConst.sintoma => AppColors.warningContainer,
    TiposEventoAgendaConst.diagnostico => AppColors.infoContainer,
    TiposEventoAgendaConst.vacuna => AppColors.successContainer,
    TiposEventoAgendaConst.actividadFisica => AppColors.habitsContainer,
    _ => AppColors.surfaceVariant,
  };
}
