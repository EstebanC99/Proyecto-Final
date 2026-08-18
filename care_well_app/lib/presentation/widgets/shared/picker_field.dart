import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Variantes visuales de [PickerField].
enum _PickerFieldVariant {
  /// Rótulo arriba y campo con borde debajo, ocupando todo el ancho.
  labeled,

  /// Píldora compacta sin rótulo, pensada para ir de a dos en una fila
  /// (fecha + hora).
  pill,
}

/// Campo de solo lectura que abre un selector (diálogo, sheet, ...) al tocarlo.
///
/// Reemplaza a los `_PickerField` privados que repetían el mismo estilo en los
/// formularios de agenda y de salud. No mantiene estado: recibe el [value] ya
/// formateado y delega la apertura del selector en [onTap]; si [onTap] es nulo
/// el campo queda inerte (formulario en modo lectura o guardando).
class PickerField extends StatelessWidget {
  /// Campo con rótulo encima, igual al que ya usan los formularios.
  const PickerField({
    super.key,
    required String this.label,
    required this.icon,
    required this.value,
    required this.onTap,
    this.trailing,
  }) : _variant = _PickerFieldVariant.labeled;

  /// Píldora compacta: ícono, valor y caret, sin rótulo arriba.
  ///
  /// Pensada para el par fecha/hora dentro de un `Row` (cada una en un
  /// [Expanded]), donde el rótulo lo aporta la sección que las agrupa.
  const PickerField.pill({
    super.key,
    required this.icon,
    required this.value,
    required this.onTap,
    this.trailing,
  }) : label = null,
       _variant = _PickerFieldVariant.pill;

  /// Rótulo del campo. Sólo aplica a la variante con rótulo.
  final String? label;

  /// Ícono a la izquierda del valor.
  final IconData icon;

  /// Valor actual, ya formateado para mostrar.
  final String value;

  /// Acción de apertura del selector. Nulo deshabilita el campo.
  final VoidCallback? onTap;

  /// Contenido opcional al final de la fila (por ejemplo, un chip de estado).
  final Widget? trailing;

  final _PickerFieldVariant _variant;

  @override
  Widget build(BuildContext context) {
    final campo = switch (_variant) {
      _PickerFieldVariant.labeled => _campoConBorde(
        context,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        radio: AppSpacing.radiusMd,
        iconColor: context.colors.textSecondary,
        valueStyle: TextStyle(fontSize: 15, color: context.colors.textPrimary),
        expandirValor: true,
        afijo: trailing,
      ),
      _PickerFieldVariant.pill => _campoConBorde(
        context,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md + 1,
        ),
        radio: AppSpacing.radiusLg,
        iconColor: context.colors.textSecondary,
        valueStyle: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: context.colors.textPrimary,
        ),
        // En la píldora el valor no se estira: el caret queda pegado al texto
        // sólo cuando sobra espacio, y el Flexible evita el overflow si no.
        expandirValor: false,
        afijo:
            trailing ??
            Icon(Icons.expand_more, size: 18, color: context.colors.primary),
      ),
    };

    if (label == null) return campo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label!),
        const SizedBox(height: AppSpacing.sm),
        campo,
      ],
    );
  }

  Widget _campoConBorde(
    BuildContext context, {
    required EdgeInsets padding,
    required double radio,
    required Color iconColor,
    required TextStyle valueStyle,
    required bool expandirValor,
    Widget? afijo,
  }) {
    final texto = Text(value, style: valueStyle);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radio),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.outline),
          borderRadius: BorderRadius.circular(radio),
          color: context.colors.surface,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
            if (expandirValor)
              Expanded(child: texto)
            else
              Flexible(child: texto),
            if (!expandirValor) const SizedBox(width: AppSpacing.xs),
            ?afijo,
          ],
        ),
      ),
    );
  }
}

/// Rótulo de campo de formulario.
///
/// Mantiene el estilo que hoy tienen los `_SectionLabel` privados de los
/// formularios (13 / w600 / secundario). Se unificará con [SectionLabel]
/// cuando cada formulario se migre al rediseño visual.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.colors.textSecondary,
      ),
    );
  }
}
