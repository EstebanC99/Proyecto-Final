import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../domain/entities/entities.dart';

/// Datos de un nivel de ánimo.
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

const _levels = [
  _MoodLevel(level: 1, emoji: '😞', label: 'Muy mal', color: AppColors.error),
  _MoodLevel(
    level: 2,
    emoji: '😕',
    label: 'Mal',
    color: AppColors.habitsAccent,
  ),
  _MoodLevel(level: 3, emoji: '😐', label: 'Regular', color: AppColors.warning),
  _MoodLevel(level: 4, emoji: '🙂', label: 'Bien', color: Color(0xFF65A30D)),
  _MoodLevel(
    level: 5,
    emoji: '😄',
    label: 'Muy bien',
    color: AppColors.success,
  ),
];

/// Selector de 5 niveles de estado de ánimo.
///
/// Cada nivel muestra un emoji y una etiqueta. El nivel seleccionado
/// se resalta con color de fondo y borde. Incluye animación spring al seleccionar.
class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key, this.selectedLevel, required this.onChanged});

  /// Nivel actualmente seleccionado (1–5), o `null` si no hay selección.
  final int? selectedLevel;

  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _levels.map((lvl) {
        final isSelected = selectedLevel == lvl.level;
        return Semantics(
          label: 'Estado ${lvl.label}',
          button: true,
          selected: isSelected,
          child: GestureDetector(
            onTap: () => onChanged(lvl.level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.elasticOut,
              width: isSelected ? 60 : 54,
              height: isSelected ? 60 : 54,
              decoration: BoxDecoration(
                color: isSelected
                    ? lvl.color.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? lvl.color : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isSelected
                  ? ElasticIn(
                      duration: const Duration(milliseconds: 300),
                      child: _MoodContent(lvl: lvl, isSelected: isSelected),
                    )
                  : _MoodContent(lvl: lvl, isSelected: isSelected),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MoodContent extends StatelessWidget {
  const _MoodContent({required this.lvl, required this.isSelected});

  final _MoodLevel lvl;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(lvl.emoji, style: TextStyle(fontSize: isSelected ? 22 : 20)),
        Text(
          lvl.label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: isSelected ? lvl.color : AppColors.textDisabled,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Convierte un nivel entero (1-5) al [EstadoAnimoEnum] correspondiente.
/// Importar desde el mismo archivo que MoodPicker para centralizar la lógica.
Color moodLevelColor(int level) {
  final found = _levels.where((l) => l.level == level).firstOrNull;
  return found?.color ?? AppColors.textDisabled;
}

/// Convierte un [EstadoAnimoEnum] a un nivel entero (1–5).
int moodLevel(EstadoAnimoEnum e) => switch (e) {
  EstadoAnimoEnum.muyMal => 1,
  EstadoAnimoEnum.mal => 2,
  EstadoAnimoEnum.regular => 3,
  EstadoAnimoEnum.bien => 4,
  EstadoAnimoEnum.muyBien => 5,
};

/// Convierte un [EstadoAnimoEnum] al emoji correspondiente.
String moodEmoji(EstadoAnimoEnum e) => switch (e) {
  EstadoAnimoEnum.muyMal => '😢',
  EstadoAnimoEnum.mal => '😕',
  EstadoAnimoEnum.regular => '😐',
  EstadoAnimoEnum.bien => '🙂',
  EstadoAnimoEnum.muyBien => '😄',
};
