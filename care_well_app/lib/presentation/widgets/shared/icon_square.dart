import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Ícono dentro de un cuadrado redondeado tintado.
///
/// Es el tratamiento estándar del ícono de una fila dentro de un `CardGroup`.
/// Por defecto usa el tinte de marca; las pantallas pasan [color] y
/// [background] con tokens de la paleta (info/infoContainer,
/// error/errorContainer, etc.) cuando una sección necesita su propio tono.
///
/// Es decorativo: no aporta semántica (la fila que lo contiene ya se anuncia).
class IconSquare extends StatelessWidget {
  const IconSquare({
    super.key,
    required this.icon,
    this.color,
    this.background,
    this.size = 38,
    this.iconSize = 18,
  });

  /// Ícono a mostrar.
  final IconData icon;

  /// Color del ícono. Por defecto el primario del tema.
  final Color? color;

  /// Color del cuadrado. Por defecto el contenedor del primario.
  final Color? background;

  /// Lado del cuadrado.
  final double size;

  /// Tamaño del ícono dentro del cuadrado.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background ?? context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: color ?? context.colors.primary,
        ),
      ),
    );
  }
}
