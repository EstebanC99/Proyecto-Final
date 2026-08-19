import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import 'timeline_categorias.dart';

/// Color de acento para una categoría de la línea de tiempo de salud.
///
/// Las categorías son las que concatena el backend en `EventoBase.categoriaEvento`:
/// `"Hábito"`, `"Evento"` y `"Ánimo"`.
Color categoriaEventoColor(BuildContext context, String categoria) {
  switch (categoria) {
    case TimelineCategorias.habito:
      return context.colors.habitsAccent;
    case TimelineCategorias.evento:
      return context.colors.healthAccent;
    case TimelineCategorias.animo:
      return context.colors.moodAccent;
    default:
      return context.colors.textSecondary;
  }
}

/// Etiqueta legible para una categoría de la línea de tiempo de salud.
String categoriaEventoLabel(String categoria) {
  switch (categoria) {
    case TimelineCategorias.habito:
      return 'Hábito';
    case TimelineCategorias.evento:
      return 'Evento de salud';
    case TimelineCategorias.animo:
      return 'Estado de ánimo';
    default:
      return categoria;
  }
}

/// Color de fondo suave para una categoría de la línea de tiempo de salud.
///
/// Espejo de [categoriaEventoColor]: mismo criterio, tono contenedor. Los tres
/// tokens ya existen en claro y en oscuro.
Color categoriaEventoContainer(BuildContext context, String categoria) {
  switch (categoria) {
    case TimelineCategorias.habito:
      return context.colors.habitsContainer;
    case TimelineCategorias.evento:
      return context.colors.healthContainer;
    case TimelineCategorias.animo:
      return context.colors.moodContainer;
    default:
      return context.colors.surfaceVariant;
  }
}

/// Etiqueta breve para una categoría, para lugares donde el ancho manda.
///
/// Convive con [categoriaEventoLabel] a propósito: al agregar una categoría
/// nueva las dos funciones quedan a la vista y se ve que hay dos rótulos que
/// completar, no uno.
String categoriaEventoLabelCorto(String categoria) {
  switch (categoria) {
    case TimelineCategorias.habito:
      return 'Hábitos';
    case TimelineCategorias.evento:
      return 'Eventos';
    case TimelineCategorias.animo:
      return 'Ánimo';
    default:
      return categoria;
  }
}
