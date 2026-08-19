import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Agrupa filas relacionadas en una tarjeta con divisores internos.
///
/// Reemplaza el patrón de filas "full bleed" pegadas al borde de la pantalla:
/// las filas ya no pintan su propio fondo ni sus separadores, los aporta este
/// contenedor. El rótulo de la sección va afuera (ver `SectionLabel`).
///
/// No tiene margen ni animación propios: el margen lateral y el `FadeInUp`
/// los pone la pantalla que lo usa.
class CardGroup extends StatelessWidget {
  const CardGroup({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  /// Filas de la tarjeta. Se separan entre sí con un divisor de 1 px.
  final List<Widget> children;

  /// Espaciado interno de la tarjeta. Por defecto las filas llegan al borde
  /// (cada fila aporta su propio padding).
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppSpacing.elev1,
      ),
      // El Material transparente habilita el ripple de los InkWell de las
      // filas: sin él, el fondo del Container los taparía.
      child: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: _conDivisores(context),
          ),
        ),
      ),
    );
  }

  /// Intercala un divisor de 1 px entre cada par de filas consecutivas.
  ///
  /// Se usa un [Container] en lugar de [Divider] para obtener exactamente 1 px
  /// sin la altura ni el sangrado que Material aplica por defecto.
  List<Widget> _conDivisores(BuildContext context) {
    final resultado = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        resultado.add(
          Container(height: 1, color: context.colors.surfaceVariant),
        );
      }
      resultado.add(children[i]);
    }
    return resultado;
  }
}
