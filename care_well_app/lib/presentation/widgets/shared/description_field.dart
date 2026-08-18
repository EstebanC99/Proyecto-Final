import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'section_label.dart';

/// Campo de texto largo con rótulo y contador propio de caracteres.
///
/// Es el bloque "descripción" de los formularios: rótulo en versales, área de
/// texto en tarjeta y contador alineado a la derecha. El contador nativo de
/// `TextField` se apaga porque queda pegado al borde y con otra tipografía.
///
/// Se suscribe al [controller] para redibujar su contador por su cuenta; el
/// padre sólo necesita [onChanged] si tiene que reevaluar algo propio (por
/// ejemplo, habilitar el botón de guardar).
class DescriptionField extends StatefulWidget {
  const DescriptionField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.accent,
    this.enabled = true,
    this.onChanged,
    this.maxLength = 500,
    this.minLines = 3,
    this.maxLines = 6,
    this.required = true,
    this.labelPadding,
  });

  final TextEditingController controller;

  /// Rótulo del campo ("Descripción").
  final String label;

  /// Texto de ayuda dentro del campo vacío.
  final String hintText;

  /// Color del borde con foco (el acento del módulo).
  final Color accent;

  final bool enabled;

  /// Se dispara con cada cambio de texto, después de actualizar el contador.
  final ValueChanged<String>? onChanged;

  /// Tope de caracteres. Es un límite de UI: mantiene el texto legible en las
  /// tarjetas y en el resumen diario.
  final int maxLength;

  final int minLines;
  final int maxLines;

  /// Marca el rótulo con el asterisco de campo obligatorio.
  final bool required;

  /// Espaciado del rótulo. Por defecto deja aire arriba para separarlo del
  /// bloque anterior.
  final EdgeInsets? labelPadding;

  @override
  State<DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<DescriptionField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_alCambiarTexto);
  }

  @override
  void didUpdateWidget(covariant DescriptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_alCambiarTexto);
      widget.controller.addListener(_alCambiarTexto);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_alCambiarTexto);
    super.dispose();
  }

  /// Redibuja el contador. El controller es del padre, así que acá no se
  /// libera; sólo se suelta el listener.
  void _alCambiarTexto() {
    if (mounted) setState(() {});
  }

  OutlineInputBorder _borde(Color color, {double ancho = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usados = widget.controller.text.characters.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          text: widget.label,
          required: widget.required,
          padding:
              widget.labelPadding ??
              const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.sm),
        ),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          // El contador nativo se apaga para pintar uno propio, alineado con
          // el resto de la tipografía del formulario.
          buildCounter:
              (
                _, {
                required int currentLength,
                required bool isFocused,
                int? maxLength,
              }) => null,
          textAlignVertical: TextAlignVertical.top,
          textCapitalization: TextCapitalization.sentences,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: context.colors.surface,
            contentPadding: const EdgeInsets.all(AppSpacing.lg),
            border: _borde(context.colors.outline),
            enabledBorder: _borde(context.colors.outline),
            disabledBorder: _borde(context.colors.outline),
            focusedBorder: _borde(widget.accent, ancho: 1.5),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$usados / ${widget.maxLength}',
            style: TextStyle(
              fontSize: 11.5,
              color: context.colors.textDisabled,
            ),
          ),
        ),
      ],
    );
  }
}
