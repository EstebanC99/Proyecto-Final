import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Rótulo de sección en versales, con contador opcional.
///
/// Separa bloques dentro de una pantalla ("SEGUIMIENTO", "PENDIENTES · 3").
/// Es puramente tipográfico: no dibuja fondo ni separadores, así que puede
/// usarse tanto dentro de un `ListView` como de un `Column`.
///
/// Usado como rótulo de un campo de formulario, [required] agrega la marca de
/// obligatorio (" *") en el color de error.
class SectionLabel extends StatelessWidget {
  const SectionLabel({
    super.key,
    required this.text,
    this.count,
    this.padding,
    this.required = false,
  });

  /// Texto del rótulo. Se muestra siempre en mayúsculas.
  final String text;

  /// Cantidad de elementos de la sección. Si no es nulo se concatena al
  /// rótulo con un separador (" · 3").
  final int? count;

  /// Espaciado alrededor del rótulo. Por defecto deja aire arriba (para
  /// separarlo del bloque anterior) y poco abajo (queda pegado a su contenido).
  final EdgeInsets? padding;

  /// Marca el campo asociado como obligatorio: agrega un asterisco en el color
  /// de error después del rótulo.
  final bool required;

  @override
  Widget build(BuildContext context) {
    final label = count == null
        ? text.toUpperCase()
        : '${text.toUpperCase()} · $count';

    const style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
    );

    return Padding(
      padding:
          padding ??
          const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
      child: Semantics(
        header: true,
        // El asterisco no se lee bien en voz alta: se reemplaza la lectura del
        // texto por una explícita que incluye la condición de obligatorio.
        label: required ? '$label, obligatorio' : null,
        excludeSemantics: required,
        child: required
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: label),
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: context.colors.error),
                    ),
                  ],
                ),
                style: style.copyWith(color: context.colors.textDisabled),
              )
            : Text(
                label,
                style: style.copyWith(color: context.colors.textDisabled),
              ),
      ),
    );
  }
}
