import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Chip pill que muestra el nombre de la persona de contexto activa.
///
/// Es un widget puramente presentacional: no contiene lógica de estado
/// ni de selección. Para la versión interactiva, ver [ContextSelector].
class ContextChip extends StatelessWidget {
  const ContextChip({
    super.key,
    required this.nombrePersona,
    this.sufijo,
    this.interactivo = false,
  });

  /// Nombre principal a mostrar en el chip.
  final String nombrePersona;

  /// Texto opcional que se muestra después del nombre (p. ej. "(Yo)").
  final String? sufijo;

  /// Cuando `true`, muestra el ícono `expand_more` al final del chip para
  /// indicar que es tappable. La lógica de tap vive en el widget padre.
  final bool interactivo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person_outline,
            size: 14,
            color: AppColors.onPrimaryContainer,
          ),
          const SizedBox(width: 5),
          Text(
            sufijo != null ? '$nombrePersona $sufijo' : nombrePersona,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimaryContainer,
            ),
          ),
          if (interactivo) ...[
            const SizedBox(width: 2),
            const Icon(
              Icons.expand_more,
              size: 14,
              color: AppColors.onPrimaryContainer,
            ),
          ],
        ],
      ),
    );
  }
}
