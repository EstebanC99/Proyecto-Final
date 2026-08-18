import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../domain/entities/entities.dart';

/// Datos visuales de un nivel de estado de ánimo.
///
/// Espejo presentacional del catálogo `EstadosAnimoConst`: asocia cada id del
/// backend con su emoji y su descripción. No conoce widgets ni `BuildContext`.
class MoodLevel {
  const MoodLevel({
    required this.level,
    required this.emoji,
    required this.label,
  });

  /// Id del catálogo de estados de ánimo ([EstadosAnimoConst]).
  final int level;

  final String emoji;

  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodLevel &&
          other.level == level &&
          other.emoji == emoji &&
          other.label == label;

  @override
  int get hashCode => Object.hash(level, emoji, label);
}

/// Niveles ordenados de peor a mejor (izquierda → derecha en el dial).
///
/// Se usan los ids de [EstadosAnimoConst] (muyBien = 1 … muyMal = 5) para que
/// el color y el emoji se resuelvan siempre por id, sin depender del orden.
const moodLevels = [
  MoodLevel(level: EstadosAnimoConst.muyMal, emoji: '😞', label: 'Muy mal'),
  MoodLevel(level: EstadosAnimoConst.mal, emoji: '😕', label: 'Mal'),
  MoodLevel(level: EstadosAnimoConst.regular, emoji: '😐', label: 'Regular'),
  MoodLevel(level: EstadosAnimoConst.bien, emoji: '🙂', label: 'Bien'),
  MoodLevel(level: EstadosAnimoConst.muyBien, emoji: '😄', label: 'Muy bien'),
];

/// Devuelve el color de escala asociado a un nivel (1–5) dentro de [palette].
/// Si el nivel no existe en el catálogo, cae a un gris neutro.
///
/// Recibe la paleta en vez del `BuildContext` para poder resolverse también
/// fuera del árbol de widgets (y para poder testearse sin montar uno).
Color moodLevelColor(AppPalette palette, int level) => switch (level) {
  EstadosAnimoConst.muyMal => palette.moodScaleVeryBad,
  EstadosAnimoConst.mal => palette.moodScaleBad,
  EstadosAnimoConst.regular => palette.moodScaleNeutral,
  EstadosAnimoConst.bien => palette.moodScaleGood,
  EstadosAnimoConst.muyBien => palette.moodScaleVeryGood,
  _ => palette.textDisabled,
};

/// Convierte un [EstadoAnimo] a un nivel entero (1–5).
///
/// El [id] de la entidad catálogo coincide con el nivel numérico.
int moodLevel(EstadoAnimo e) => e.id;

/// Devuelve el emoji asociado a un [EstadoAnimo], resuelto por id.
String moodEmoji(EstadoAnimo e) => moodEmojiForLevel(e.id);

/// Devuelve el emoji asociado a un nivel (1–5) del catálogo de ánimo.
///
/// Variante por id para los casos en que el origen de datos manda el nivel
/// suelto, sin la entidad (por ejemplo el resumen de salud del hub).
String moodEmojiForLevel(int level) {
  final found = moodLevels.where((l) => l.level == level).firstOrNull;
  return found?.emoji ?? '😐';
}

/// Devuelve la descripción de un nivel (1–5) del catálogo de ánimo.
///
/// Espejo local del catálogo del backend (ver `EstadosAnimoConst`): lo usa el
/// hub, que recibe sólo el id del estado registrado.
String? moodLabelForLevel(int level) =>
    moodLevels.where((l) => l.level == level).firstOrNull?.label;
