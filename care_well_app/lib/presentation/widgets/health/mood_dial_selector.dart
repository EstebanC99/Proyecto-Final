import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../domain/entities/entities.dart';

/// Datos visuales de un nivel de estado de ánimo.
class _MoodLevel {
  const _MoodLevel({
    required this.level,
    required this.emoji,
    required this.label,
  });

  final int level;
  final String emoji;
  final String label;
}

/// Niveles ordenados de peor a mejor (izquierda → derecha en el dial).
///
/// Se usan los ids de [EstadosAnimoConst] (muyBien = 1 … muyMal = 5) para que
/// el color y el emoji se resuelvan siempre por id, sin depender del orden.
const _levels = [
  _MoodLevel(level: EstadosAnimoConst.muyMal, emoji: '😞', label: 'Muy mal'),
  _MoodLevel(level: EstadosAnimoConst.mal, emoji: '😕', label: 'Mal'),
  _MoodLevel(level: EstadosAnimoConst.regular, emoji: '😐', label: 'Regular'),
  _MoodLevel(level: EstadosAnimoConst.bien, emoji: '🙂', label: 'Bien'),
  _MoodLevel(level: EstadosAnimoConst.muyBien, emoji: '😄', label: 'Muy bien'),
];

/// Selector tipo dial/carrusel de estado de ánimo (US-31).
///
/// Muestra un emoji grande dentro de un "blob" coloreado según el nivel, con
/// flechas para navegar entre los 5 niveles (peor → mejor) y una fila de dots
/// que refuerza la posición dentro de la escala. El nivel se controla desde el
/// padre vía [selectedLevel] y los cambios se notifican con [onChanged].
class MoodDialSelector extends StatelessWidget {
  const MoodDialSelector({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
  });

  /// Nivel actualmente mostrado (ids de [EstadosAnimoConst]).
  final int selectedLevel;

  final ValueChanged<int> onChanged;

  int get _index {
    final i = _levels.indexWhere((l) => l.level == selectedLevel);
    return i < 0 ? 2 : i; // por defecto "Regular" (posición central)
  }

  @override
  Widget build(BuildContext context) {
    final index = _index;
    final current = _levels[index];
    final canPrev = index > 0;
    final canNext = index < _levels.length - 1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DialArrow(
              icon: Icons.chevron_left,
              enabled: canPrev,
              semanticLabel: 'Empeorar el estado, tocá para cambiar.',
              onPressed: canPrev
                  ? () => onChanged(_levels[index - 1].level)
                  : null,
            ),
            const SizedBox(width: 16),
            _MoodBlob(level: current),
            const SizedBox(width: 16),
            _DialArrow(
              icon: Icons.chevron_right,
              enabled: canNext,
              semanticLabel: 'Mejorar el estado, tocá para cambiar.',
              onPressed: canNext
                  ? () => onChanged(_levels[index + 1].level)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Text(
            current.label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _levels.length; i++)
              _Dot(
                active: i == index,
                color: moodLevelColor(context.colors, current.level),
              ),
          ],
        ),
      ],
    );
  }
}

/// Blob circular con el emoji del nivel; fondo al alpha de la paleta
/// ([AppPalette.moodBlobAlpha]) y anillo al 100%.
class _MoodBlob extends StatelessWidget {
  const _MoodBlob({required this.level});

  final _MoodLevel level;

  @override
  Widget build(BuildContext context) {
    final color = moodLevelColor(context.colors, level.level);

    return Semantics(
      label: 'Estado ${level.label}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 156,
        height: 156,
        decoration: BoxDecoration(
          color: color.withValues(alpha: context.colors.moodBlobAlpha),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
        ),
        child: Center(
          child: ZoomIn(
            key: ValueKey(level.level),
            duration: const Duration(milliseconds: 250),
            child: Text(
              level.emoji,
              style: const TextStyle(fontSize: 64, height: 1),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flecha de navegación del dial. Se deshabilita en los extremos de la escala.
class _DialArrow extends StatelessWidget {
  const _DialArrow({
    required this.icon,
    required this.enabled,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 32,
      color: context.colors.textSecondary,
      disabledColor: context.colors.textDisabled.withValues(alpha: 0.5),
      constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
      tooltip: enabled ? semanticLabel : null,
      icon: Icon(icon, semanticLabel: semanticLabel),
    );
  }
}

/// Punto indicador de posición dentro de la escala.
class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 10 : 8,
      height: active ? 10 : 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : context.colors.outline,
      ),
    );
  }
}

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
String moodEmoji(EstadoAnimo e) {
  final found = _levels.where((l) => l.level == e.id).firstOrNull;
  return found?.emoji ?? '😐';
}
