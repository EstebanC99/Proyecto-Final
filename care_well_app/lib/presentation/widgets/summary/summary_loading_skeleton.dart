import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Skeleton de carga de la pantalla de Resumen (US 9.16).
///
/// Reproduce la silueta del contenido real —franja del día y tres cards con
/// encabezado— con el mismo pulso de opacidad que [NavTileSkeleton], y anuncia
/// "Armando el resumen del día…" en [AppPalette.aiAccent] para que la espera de
/// la IA se lea como trabajo en curso y no como una demora sin explicación.
class SummaryLoadingSkeleton extends StatefulWidget {
  const SummaryLoadingSkeleton({super.key});

  @override
  State<SummaryLoadingSkeleton> createState() => _SummaryLoadingSkeletonState();
}

class _SummaryLoadingSkeletonState extends State<SummaryLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Aviso + franja del día.
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: context.colors.aiAccent,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Armando el resumen del día…',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.colors.aiAccent,
                    ),
                  ),
                ),
                const _Barra(width: 120, height: 26, radius: 999),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Cards: la primera más alta (anillo + pills de hábitos).
            const _CardEsqueleto(lineas: [1.0, 0.7], alturaBloque: 82),
            const SizedBox(height: AppSpacing.md),
            const _CardEsqueleto(lineas: [0.95, 0.6]),
            const SizedBox(height: AppSpacing.md),
            const _CardEsqueleto(lineas: [0.9]),
          ],
        ),
      ),
    );
  }
}

/// Silueta de una card: caja de ícono, título y algunas líneas de contenido.
class _CardEsqueleto extends StatelessWidget {
  const _CardEsqueleto({required this.lineas, this.alturaBloque});

  /// Anchos relativos de las líneas de contenido.
  final List<double> lineas;

  /// Alto de un bloque destacado antes de las líneas (ej. el anillo).
  final double? alturaBloque;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppSpacing.elev1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _Barra(width: 44, height: 44, radius: AppSpacing.radiusMd),
              const SizedBox(width: AppSpacing.md),
              const _Barra(width: 140, height: 14),
              const Spacer(),
              const _Barra(width: 48, height: 12),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (alturaBloque != null) ...[
            _Barra(width: alturaBloque!, height: alturaBloque!, radius: 999),
            const SizedBox(height: AppSpacing.md),
          ],
          for (final (indice, ancho) in lineas.indexed) ...[
            if (indice > 0) const SizedBox(height: AppSpacing.sm),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ancho,
              child: const _Barra(height: 12),
            ),
          ],
        ],
      ),
    );
  }
}

/// Bloque gris del skeleton.
class _Barra extends StatelessWidget {
  const _Barra({this.width, required this.height, this.radius});

  final double? width;
  final double height;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(radius ?? AppSpacing.radiusSm),
      ),
    );
  }
}
