import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Tile de emergencia full-width. Siempre visible y activo.
///
/// Fondo [AppColors.secondary] (coral). Icono + texto blancos.
/// Estado pressed: fondo ligeramente más oscuro.
class EmergencyTile extends StatefulWidget {
  const EmergencyTile({
    super.key,
    required this.onTap,
    this.delay = Duration.zero,
  });

  final VoidCallback onTap;

  /// Delay para la animación de entrada FadeInUp.
  final Duration delay;

  @override
  State<EmergencyTile> createState() => _EmergencyTileState();
}

class _EmergencyTileState extends State<EmergencyTile> {
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
                ? AppColors.secondary.withValues(alpha: 0.9)
                : AppColors.secondary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.md),
                const Text(
                  'Emergencia',
                  style: TextStyle(
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
