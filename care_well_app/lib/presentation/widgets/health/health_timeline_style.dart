import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Color de acento para una categoría de la línea de tiempo de salud.
///
/// Las categorías son las que concatena el backend en `EventoBase.categoriaEvento`:
/// `"Hábito"`, `"Evento"` y `"Ánimo"`.
Color categoriaEventoColor(String categoria) {
  switch (categoria) {
    case 'Hábito':
      return AppColors.habitsAccent;
    case 'Evento':
      return AppColors.healthAccent;
    case 'Ánimo':
      return AppColors.moodAccent;
    default:
      return AppColors.textSecondary;
  }
}

/// Etiqueta legible para una categoría de la línea de tiempo de salud.
String categoriaEventoLabel(String categoria) {
  switch (categoria) {
    case 'Hábito':
      return 'Hábito';
    case 'Evento':
      return 'Evento de salud';
    case 'Ánimo':
      return 'Estado de ánimo';
    default:
      return categoria;
  }
}
