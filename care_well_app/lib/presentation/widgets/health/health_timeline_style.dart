import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';

/// Color de acento para una categoría de la línea de tiempo de salud.
///
/// Las categorías son las que concatena el backend en `EventoBase.categoriaEvento`:
/// `"Hábito"`, `"Evento"` y `"Ánimo"`.
Color categoriaEventoColor(BuildContext context, String categoria) {
  switch (categoria) {
    case 'Hábito':
      return context.colors.habitsAccent;
    case 'Evento':
      return context.colors.healthAccent;
    case 'Ánimo':
      return context.colors.moodAccent;
    default:
      return context.colors.textSecondary;
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
