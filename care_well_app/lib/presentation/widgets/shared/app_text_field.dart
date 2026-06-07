import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onEditingComplete,
    this.textInputAction,
    // Parámetros nuevos — todos opcionales para no romper usos existentes.
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.helperText,
    this.autocorrect = true,
    this.autofillHints,
    this.onSubmitted,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;

  /// Capitalización del texto. Por defecto [TextCapitalization.none].
  final TextCapitalization textCapitalization;

  /// Nodo de foco externo para controlar el foco programáticamente.
  final FocusNode? focusNode;

  /// Texto de ayuda persistente bajo el campo (se muestra cuando no hay error).
  final String? helperText;

  /// Si es `true` el sistema puede autocorregir el texto. Default `true`.
  final bool autocorrect;

  /// Sugerencias de autocompletado del sistema operativo.
  final Iterable<String>? autofillHints;

  /// Callback al presionar "enviar/siguiente" en el teclado.
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        focusNode: focusNode,
        autocorrect: autocorrect,
        autofillHints: autofillHints,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          errorText: errorText,
          helperText: helperText,
        ),
      ),
    ],
  );
}
