import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Chip de estado para una enfermedad: "Activa" (vigente) o "Resuelta".
///
/// Representación visual del booleano `vigente`; nunca es la única señal de
/// estado (el título del ítem la acompaña).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.vigente});

  final bool vigente;

  @override
  Widget build(BuildContext context) {
    final bg = vigente
        ? context.colors.warningContainer
        : context.colors.successContainer;
    // Variante oscurecida del warning para cumplir contraste AA sobre el
    // contenedor claro (ver sistema de diseño §3.6).
    final fg = vigente ? const Color(0xFF8A6400) : context.colors.success;
    final label = vigente ? 'Activa' : 'Resuelta';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
