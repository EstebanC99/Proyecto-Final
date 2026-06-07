import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Variante de [NavTile] para el estado vacío de "Personas a cargo".
///
/// El fondo del tile usa un tinte suave de [accentColor] y el círculo del
/// ícono usa [accentColor] con opacidad reducida para indicar estado vacío.
/// Incluye un botón [+] en la esquina superior derecha para alta directa.
class EmptyStateTile extends StatefulWidget {
  const EmptyStateTile({
    super.key,
    required this.accentColor,
    required this.onTap,
    required this.onTapAdd,
  });

  /// Color de acento del tile: define el círculo del ícono y el tinte del fondo.
  final Color accentColor;

  /// Toca el cuerpo del tile → navega al listado de personas a cargo.
  final VoidCallback onTap;

  /// Toca el botón + → navega directamente al formulario de alta.
  final VoidCallback onTapAdd;

  @override
  State<EmptyStateTile> createState() => _EmptyStateTileState();
}

class _EmptyStateTileState extends State<EmptyStateTile> {
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
              ? widget.accentColor.withValues(alpha: 0.25)
              : widget.accentColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
        child: Stack(
          children: [
            // Contenido central
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Círculo de color apagado con ícono blanco adentro (estado vacío)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withValues(alpha: 0.40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.elderly,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Aún no tenés\npersonas a cargo',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            // Botón + en esquina superior derecha
            Positioned(
              top: -8,
              right: -8,
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  iconSize: 24,
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: widget.accentColor,
                  ),
                  onPressed: widget.onTapAdd,
                  tooltip: 'Agregar persona a cargo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
