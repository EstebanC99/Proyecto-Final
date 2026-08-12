import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';

import '../../../config/theme/app_spacing.dart';

/// Variante visual de [FullWidthActionTile].
enum FullWidthActionTileStyle {
  /// Relleno sólido con el color de acento. Máxima jerarquía visual.
  filled,

  /// Fondo de superficie con borde del color de acento. Jerarquía secundaria.
  outlined,
}

/// Tile de acción full-width con ícono + texto.
///
/// Alto mínimo de 72 dp —crece si el contenido lo necesita—, animación de
/// entrada [FadeInUp] y estado pressed. Reutilizado por accesos destacados como
/// el tile de emergencia y el acceso a la línea de tiempo de salud (ambos en la
/// variante [FullWidthActionTileStyle.filled]).
class FullWidthActionTile extends StatefulWidget {
  const FullWidthActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.style = FullWidthActionTileStyle.filled,
    this.foregroundColor,
    this.pressedColor,
    this.delay = Duration.zero,
  });

  final IconData icon;
  final String label;

  /// Color de acento: relleno en [FullWidthActionTileStyle.filled], borde en
  /// [FullWidthActionTileStyle.outlined].
  final Color color;

  final VoidCallback onTap;

  /// Variante visual del tile.
  final FullWidthActionTileStyle style;

  /// Tinta del ícono y del texto.
  ///
  /// Si es `null` se resuelve según la variante: `onPrimary` en `filled` y
  /// [color] en `outlined`. Conviene especificarlo cuando el acento no
  /// contrasta con `onPrimary` (por ejemplo el rojo de emergencia en oscuro).
  final Color? foregroundColor;

  /// Relleno del estado presionado en [FullWidthActionTileStyle.filled].
  ///
  /// Si es `null` se usa [color] atenuado. No aplica a la variante `outlined`,
  /// que resuelve el pressed como un tinte suave del acento.
  final Color? pressedColor;

  /// Delay para la animación de entrada [FadeInUp].
  final Duration delay;

  @override
  State<FullWidthActionTile> createState() => _FullWidthActionTileState();
}

class _FullWidthActionTileState extends State<FullWidthActionTile> {
  bool _pressed = false;

  bool get _isOutlined => widget.style == FullWidthActionTileStyle.outlined;

  /// Tinta del ícono y del texto según la variante.
  Color _resolveForeground(BuildContext context) =>
      widget.foregroundColor ??
      (_isOutlined ? widget.color : context.colors.onPrimary);

  /// Color de fondo según la variante y el estado pressed.
  ///
  /// En `outlined` el pressed no oscurece el fondo (parecería deshabilitado):
  /// aplica un tinte suave del acento manteniendo el borde.
  Color _resolveBackground(BuildContext context) {
    if (_isOutlined) {
      return _pressed
          ? Color.alphaBlend(
              widget.color.withValues(alpha: 0.08),
              context.colors.surface,
            )
          : context.colors.surface;
    }
    if (!_pressed) return widget.color;
    return widget.pressedColor ?? widget.color.withValues(alpha: 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final foreground = _resolveForeground(context);

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      delay: widget.delay,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          // Alto mínimo, no fijo: con escalas tipográficas grandes el tile
          // crece en lugar de recortar el contenido.
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            color: _resolveBackground(context),
            border: _isOutlined
                ? Border.all(color: widget.color, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          // El Align estira el tile a todo el ancho disponible; `heightFactor`
          // evita que además estire el alto, que lo define el contenido (con
          // el mínimo de 72 dp del contenedor).
          child: Align(
            heightFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 32, color: foreground),
                  const SizedBox(width: AppSpacing.md),
                  // Flexible: en pantallas angostas o con tipografía grande el
                  // label cede espacio en lugar de desbordar la fila.
                  Flexible(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
