import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Disposición de [HealthMetricCard].
enum HealthMetricCardLayout {
  /// Tarjeta vertical, pensada para ir de a dos por fila.
  grid,

  /// Tile horizontal de ancho completo, con chevron a la derecha.
  wide,
}

/// Tarjeta de acceso a un submódulo de salud con una métrica del día.
///
/// La métrica se arma con tres partes opcionales (prefijo, valor destacado y
/// sufijo) para poder expresar tanto "Hoy: **alegre**" como
/// "**2 de 5** completados hoy" o, si el dato no está disponible todavía, sólo
/// un copy de vacío ("Sin registro hoy") sin dibujar un guion feo.
class HealthMetricCard extends StatefulWidget {
  const HealthMetricCard({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.containerColor,
    required this.label,
    required this.onTap,
    this.metricPrefix,
    this.metricValue,
    this.metricSuffix,
    this.layout = HealthMetricCardLayout.grid,
    this.delay = Duration.zero,
  });

  final IconData icon;
  final Color accentColor;
  final Color containerColor;
  final String label;
  final VoidCallback onTap;

  /// Texto neutro previo al valor ("Hoy: ", "Último: ").
  final String? metricPrefix;

  /// Valor destacado de la métrica. Si es `null` no se dibuja.
  final String? metricValue;

  /// Texto neutro posterior al valor. Cuando no hay valor, funciona como copy
  /// de estado vacío.
  final String? metricSuffix;

  final HealthMetricCardLayout layout;

  /// Delay de la animación de entrada [FadeInUp].
  final Duration delay;

  @override
  State<HealthMetricCard> createState() => _HealthMetricCardState();
}

class _HealthMetricCardState extends State<HealthMetricCard> {
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            // El pressed no cambia de color la card: la tiñe apenas con el
            // acento para no parecer deshabilitada.
            color: _pressed
                ? Color.alphaBlend(
                    widget.accentColor.withValues(alpha: 0.06),
                    context.colors.surface,
                  )
                : context.colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: _pressed ? AppSpacing.elev0 : AppSpacing.elev1,
          ),
          child: widget.layout == HealthMetricCardLayout.grid
              ? _buildGrid(context)
              : _buildWide(context),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _icono(context),
        const SizedBox(height: 11),
        _titulo(context),
        const SizedBox(height: 5),
        _metrica(context),
      ],
    );
  }

  Widget _buildWide(BuildContext context) {
    return Row(
      children: [
        _icono(context),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titulo(context),
              const SizedBox(height: 5),
              _metrica(context),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(Icons.chevron_right, size: 20, color: context.colors.textDisabled),
      ],
    );
  }

  Widget _icono(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: widget.containerColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(widget.icon, size: 20, color: widget.accentColor),
    );
  }

  Widget _titulo(BuildContext context) {
    return Text(
      widget.label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: context.colors.textPrimary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _metrica(BuildContext context) {
    final neutro = TextStyle(
      fontSize: 12.5,
      color: context.colors.textSecondary,
      height: 1.3,
    );

    return Text.rich(
      TextSpan(
        children: [
          if (widget.metricPrefix != null && widget.metricValue != null)
            TextSpan(text: widget.metricPrefix),
          if (widget.metricValue != null)
            TextSpan(
              text: widget.metricValue,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          if (widget.metricSuffix != null) TextSpan(text: widget.metricSuffix),
        ],
      ),
      style: neutro,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
