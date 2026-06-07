import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Card cuadrada de categoría de salud para el hub Mi salud.
///
/// Muestra un círculo de color con ícono blanco, una etiqueta,
/// opcionalmente una descripción breve y el último registro (fecha o texto breve).
class HealthCategoryCard extends StatefulWidget {
  const HealthCategoryCard({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.label,
    this.description,
    this.lastRecord,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final String label;

  /// Descripción breve de la categoría, se muestra debajo del label.
  final String? description;

  /// Texto breve del último registro (fecha u observación corta).
  final String? lastRecord;

  final VoidCallback onTap;

  @override
  State<HealthCategoryCard> createState() => _HealthCategoryCardState();
}

class _HealthCategoryCardState extends State<HealthCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: _pressed
              ? widget.accentColor.withValues(alpha: 0.18)
              : widget.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: _pressed ? AppSpacing.elev0 : AppSpacing.elev1,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Círculo con ícono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.accentColor,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 24, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Etiqueta
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.description != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.description!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (widget.lastRecord != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.lastRecord!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Chevron alineado a la derecha
            Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.chevron_right,
                size: 16,
                color: widget.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
