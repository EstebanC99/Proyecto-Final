import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Rótulo de sección en versales, con contador opcional.
///
/// Separa bloques dentro de una pantalla ("SEGUIMIENTO", "PENDIENTES · 3").
/// Es puramente tipográfico: no dibuja fondo ni separadores, así que puede
/// usarse tanto dentro de un `ListView` como de un `Column`.
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.text, this.count, this.padding});

  /// Texto del rótulo. Se muestra siempre en mayúsculas.
  final String text;

  /// Cantidad de elementos de la sección. Si no es nulo se concatena al
  /// rótulo con un separador (" · 3").
  final int? count;

  /// Espaciado alrededor del rótulo. Por defecto deja aire arriba (para
  /// separarlo del bloque anterior) y poco abajo (queda pegado a su contenido).
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final label = count == null
        ? text.toUpperCase()
        : '${text.toUpperCase()} · $count';

    return Padding(
      padding:
          padding ??
          const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: context.colors.textDisabled,
          ),
        ),
      ),
    );
  }
}
