import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_spacing.dart';

/// Tile de acción full-width con ícono + texto sobre fondo de color sólido.
///
/// Layout de 72 dp de alto, animación de entrada [FadeInUp] y estado pressed
/// (fondo ligeramente más oscuro). Reutilizado por accesos destacados como el
/// tile de emergencia y el acceso a la línea de tiempo de salud.
class FullWidthActionTile extends StatefulWidget {
  const FullWidthActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.delay = Duration.zero,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  /// Delay para la animación de entrada [FadeInUp].
  final Duration delay;

  @override
  State<FullWidthActionTile> createState() => _FullWidthActionTileState();
}

class _FullWidthActionTileState extends State<FullWidthActionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
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
            color: _pressed
                ? widget.color.withValues(alpha: 0.9)
                : widget.color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 32, color: Colors.white),
                const SizedBox(width: AppSpacing.md),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
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
