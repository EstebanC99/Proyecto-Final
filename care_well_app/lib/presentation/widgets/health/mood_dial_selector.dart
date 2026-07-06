import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';

/// Datos visuales de un nivel de estado de ánimo.
class _MoodLevel {
  const _MoodLevel({
    required this.level,
    required this.emoji,
    required this.label,
    required this.color,
  });

  final int level;
  final String emoji;
  final String label;
  final Color color;
}

/// Niveles ordenados de peor a mejor (izquierda → derecha en el dial).
///
/// Se usan los ids de [EstadosAnimoConst] (muyBien = 1 … muyMal = 5) para que
/// el color y el emoji se resuelvan siempre por id, sin depender del orden.
const _levels = [
  _MoodLevel(
    level: EstadosAnimoConst.muyMal,
    emoji: '😞',
    label: 'Muy mal',
    color: AppColors.moodScaleVeryBad,
  ),
  _MoodLevel(
    level: EstadosAnimoConst.mal,
    emoji: '😕',
    label: 'Mal',
    color: AppColors.moodScaleBad,
  ),
  _MoodLevel(
    level: EstadosAnimoConst.regular,
    emoji: '😐',
    label: 'Regular',
    color: AppColors.moodScaleNeutral,
  ),
  _MoodLevel(
    level: EstadosAnimoConst.bien,
    emoji: '🙂',
    label: 'Bien',
    color: AppColors.moodScaleGood,
  ),
  _MoodLevel(
    level: EstadosAnimoConst.muyBien,
    emoji: '😄',
    label: 'Muy bien',
    color: AppColors.moodScaleVeryGood,
  ),
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _levels.length; i++)
              _Dot(active: i == index, color: current.color),
          ],
        ),
      ],
    );
  }
}

/// Blob circular con el emoji del nivel; fondo al 16% y anillo al 100%.
class _MoodBlob extends StatelessWidget {
  const _MoodBlob({required this.level});

  final _MoodLevel level;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Estado ${level.label}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 156,
        height: 156,
        decoration: BoxDecoration(
          color: level.color.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(color: level.color, width: 3),
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
      color: AppColors.textSecondary,
      disabledColor: AppColors.textDisabled.withValues(alpha: 0.5),
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
        color: active ? color : AppColors.outline,
      ),
    );
  }
}

/// Devuelve el color de escala asociado a un nivel (1–5). Si el nivel no existe
/// en el catálogo, cae a un gris neutro.
Color moodLevelColor(int level) {
  final found = _levels.where((l) => l.level == level).firstOrNull;
  return found?.color ?? AppColors.textDisabled;
}

/// Convierte un [EstadoAnimo] a un nivel entero (1–5).
///
/// El [id] de la entidad catálogo coincide con el nivel numérico.
int moodLevel(EstadoAnimo e) => e.id;

/// Devuelve el emoji asociado a un [EstadoAnimo], resuelto por id.
String moodEmoji(EstadoAnimo e) {
  final found = _levels.where((l) => l.level == e.id).firstOrNull;
  return found?.emoji ?? '😐';
}
