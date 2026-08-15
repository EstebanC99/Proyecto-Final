import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Tile de navegación para el grid 2×2 del menú principal.
///
/// Muestra un círculo de color con el [icon] en blanco centrado arriba, un
/// [label] centrado abajo y, opcionalmente, una [description] de apoyo. El
/// fondo del tile usa un tinte suave del mismo [accentColor].
/// El estado pressed oscurece el fondo y elimina la sombra.
///
/// La altura no es fija: la define el contenido. Es responsabilidad de la
/// pantalla contenedora igualar la altura de los tiles de una misma fila
/// (por ejemplo con `IntrinsicHeight`), para que una descripción de dos
/// líneas no desalinee el grid con escalas de fuente grandes.
class NavTile extends StatefulWidget {
  const NavTile({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.description,
    this.delay = Duration.zero,
    this.badge,
  });

  final IconData icon;
  final String label;

  /// Texto corto de apoyo bajo el [label]. Cuando es `null` el tile se
  /// renderiza igual que antes de existir este parámetro.
  final String? description;

  /// Color de acento del tile: define el círculo del ícono y el tinte del fondo.
  final Color accentColor;

  final VoidCallback onTap;

  /// Delay para la animación de entrada FadeInUp. Lo gestiona la pantalla.
  final Duration delay;

  /// Widget opcional superpuesto en la esquina superior derecha del círculo
  /// de ícono. Cuando es null, el tile se renderiza de forma idéntica al estado
  /// anterior (sin impacto en el layout).
  final Widget? badge;

  @override
  State<NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<NavTile> {
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
          decoration: BoxDecoration(
            color: _pressed
                ? widget.accentColor.withValues(alpha: 0.25)
                : widget.accentColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: _pressed ? AppSpacing.elev0 : AppSpacing.elev1,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Círculo de color con ícono blanco adentro, con badge opcional.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 30,
                      color: context.colors.onPrimary,
                    ),
                  ),
                  if (widget.badge != null)
                    Positioned(top: -4, right: -4, child: widget.badge!),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: context.colors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.description != null) ...[
                const SizedBox(height: 3),
                Text(
                  widget.description!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    color: context.colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
