import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
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
    this.enabled = true,
    this.loading = false,
  });

  final IconData icon;
  final Color accentColor;
  final String label;

  /// Descripción breve de la categoría, se muestra debajo del label.
  final String? description;

  /// Texto breve del último registro (fecha u observación corta).
  final String? lastRecord;

  final VoidCallback onTap;

  /// Cuando es `false`, la card se muestra atenuada, con un candado en lugar
  /// del chevron y sin responder al tap (p. ej. sin permiso para entrar).
  final bool enabled;

  /// Cuando es `true`, el estado de habilitación todavía se está determinando
  /// (p. ej. un permiso asíncrono en curso). Se muestra un estado neutro —sin
  /// candado ni chevron activo, con un indicador de carga en el trailing— para
  /// evitar el parpadeo de "bloqueada→desbloqueada" mientras resuelve. Tiene
  /// prioridad sobre [enabled].
  final bool loading;

  @override
  State<HealthCategoryCard> createState() => _HealthCategoryCardState();
}

class _HealthCategoryCardState extends State<HealthCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final loading = widget.loading;
    // Mientras se determina el permiso, la card no está ni bloqueada ni
    // habilitada: se ignora [enabled] para no pintar un candado transitorio.
    final enabled = !loading && widget.enabled;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: _pressed
            ? widget.accentColor.withValues(alpha: 0.18)
            : widget.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: _pressed ? AppSpacing.elev0 : AppSpacing.elev1,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: _buildContent(enabled, loading),
    );

    // Estado neutro de carga: opacidad plena (sin atenuar) y sin tap, para que
    // la transición a habilitada sea sólo spinner→chevron, sin saltos.
    if (loading) {
      return card;
    }

    if (!enabled) {
      return Opacity(opacity: 0.5, child: card);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: card,
    );
  }

  Widget _buildContent(bool enabled, bool loading) {
    return Column(
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
          child: Icon(widget.icon, size: 24, color: context.colors.onPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Etiqueta
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.description != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.description!,
            style: TextStyle(
              fontSize: 11,
              color: context.colors.textSecondary,
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
            style: TextStyle(fontSize: 11, color: context.colors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // Trailing: indicador de carga mientras se determina el permiso;
        // luego chevron (habilitada) o candado (bloqueada).
        Align(
          alignment: Alignment.centerRight,
          child: loading
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.accentColor,
                    ),
                  ),
                )
              : Icon(
                  enabled ? Icons.chevron_right : Icons.lock_outline,
                  size: 16,
                  color: widget.accentColor,
                ),
        ),
      ],
    );
  }
}
