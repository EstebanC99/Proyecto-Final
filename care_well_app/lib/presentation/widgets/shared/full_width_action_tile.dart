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
/// Layout de 72 dp de alto, animación de entrada [FadeInUp] y estado pressed.
/// Reutilizado por accesos destacados como el tile de emergencia (variante
/// [FullWidthActionTileStyle.filled]) y el acceso a la línea de tiempo de salud
/// (variante [FullWidthActionTileStyle.outlined]).
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
          height: 72,
          decoration: BoxDecoration(
            color: _resolveBackground(context),
            border: _isOutlined
                ? Border.all(color: widget.color, width: 1.5)
                : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 32, color: foreground),
                const SizedBox(width: AppSpacing.md),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
