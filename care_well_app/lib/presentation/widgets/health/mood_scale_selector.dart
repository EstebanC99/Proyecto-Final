import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'mood_scale.dart';

/// Selector de estado de ánimo: los cinco niveles a la vista, en una fila.
///
/// Reemplaza al dial de flechas, que obligaba a navegar de a un nivel por vez
/// para llegar a los extremos. Acá elegir es un solo toque y la escala completa
/// se lee de un vistazo, de peor a mejor (el orden de [moodLevels]).
///
/// [selectedLevel] es nullable a propósito: la pantalla arranca sin selección,
/// para no sugerir un estado que el usuario no eligió.
class MoodScaleSelector extends StatelessWidget {
  const MoodScaleSelector({
    super.key,
    required this.selectedLevel,
    required this.onChanged,
    this.enabled = true,
  });

  /// Nivel elegido (ids de `EstadosAnimoConst`). `null` si todavía no se eligió.
  final int? selectedLevel;

  /// Emite el nivel del tile tocado.
  final ValueChanged<int> onChanged;

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    // Las cinco opciones comparten alto, y ese alto lo manda el contenido: con
    // la tipografía del sistema grande, "Muy bien" ocupa dos renglones y un
    // alto fijo lo recortaría.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final nivel in moodLevels) ...[
            if (nivel != moodLevels.first) const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MoodTile(
                nivel: nivel,
                seleccionado: nivel.level == selectedLevel,
                onTap: enabled ? () => onChanged(nivel.level) : null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta de un nivel: emoji arriba, descripción abajo.
class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.nivel,
    required this.seleccionado,
    required this.onTap,
  });

  final MoodLevel nivel;
  final bool seleccionado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = moodLevelColor(colors, nivel.level);

    return Semantics(
      button: true,
      selected: seleccionado,
      label: nivel.label,
      // Sin esto el lector de pantalla anuncia también el nombre Unicode del
      // emoji ("cara ligeramente sonriente") además de la descripción.
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(4, 13, 4, 11),
            decoration: BoxDecoration(
              color: seleccionado
                  ? color.withValues(alpha: colors.moodBlobAlpha)
                  : colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              // El borde está siempre: transparente sin selección, para que
              // elegir no cambie el tamaño del tile.
              border: Border.all(
                color: seleccionado ? color : Colors.transparent,
                width: 2,
              ),
              boxShadow: AppSpacing.elev1,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // `AnimatedScale` pinta el emoji más grande sin ocupar más
                // lugar: con un alto intrínseco compartido, agrandarlo de
                // verdad estiraría las cinco tarjetas al seleccionar.
                AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  scale: seleccionado ? 1.12 : 1,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: seleccionado ? 1 : 0.55,
                    child: Text(
                      nivel.emoji,
                      style: const TextStyle(fontSize: 26, height: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nivel.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: seleccionado
                        ? FontWeight.w700
                        : FontWeight.w600,
                    // Sin elegir va en `textSecondary` y no en `textDisabled`
                    // como el mockup: son los nombres de las cinco opciones, o
                    // sea el contenido principal de la pantalla, y a 10.5sp el
                    // gris más claro no llega al contraste AA.
                    color: seleccionado ? color : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
