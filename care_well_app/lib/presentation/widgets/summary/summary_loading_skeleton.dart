import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Skeleton de carga de la pantalla de Resumen (US 9.16).
///
/// Muestra 4-5 barras con el mismo pulso de opacidad que [NavTileSkeleton] y el
/// texto "Redactando tu resumen…" en [AppColors.aiAccent]. Se usa en lugar de
/// un spinner genérico, para reforzar que el contenido se está "escribiendo".
class SummaryLoadingSkeleton extends StatefulWidget {
  const SummaryLoadingSkeleton({super.key});

  @override
  State<SummaryLoadingSkeleton> createState() => _SummaryLoadingSkeletonState();
}

class _SummaryLoadingSkeletonState extends State<SummaryLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  /// Anchos relativos de cada barra, para que el bloque parezca un párrafo real.
  static const List<double> _anchos = [1.0, 0.95, 0.88, 0.97, 0.6];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppSpacing.elev1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: AppColors.aiAccent),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Redactando tu resumen…',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.aiAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final ancho in _anchos) ...[
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: ancho,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
                if (ancho != _anchos.last)
                  const SizedBox(height: AppSpacing.md),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
