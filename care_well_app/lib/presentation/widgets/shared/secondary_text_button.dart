import 'package:flutter/material.dart';

/// Botón de texto secundario reutilizable.
///
/// Aplica el estilo secundario del theme (color `primary`, sin fondo ni borde).
/// Usar para acciones secundarias o de navegación alternativa.
class SecondaryTextButton extends StatelessWidget {
  const SecondaryTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: const Size(0, 48),
        textStyle: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}
