import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'status_chip.dart';

/// Fila de un ítem de una lista de la Ficha de salud (antecedente, alergia o
/// enfermedad). Tap en el cuerpo edita; el ícono de borrado quita el ítem.
class HealthListItemCard extends StatelessWidget {
  const HealthListItemCard({
    super.key,
    required this.title,
    required this.subtitles,
    required this.accent,
    this.onTap,
    this.onDelete,
    this.vigente,
  });

  /// Título del ítem (nombre).
  final String title;

  /// Líneas secundarias (descripción, reacción, vínculo, etc.).
  final List<String> subtitles;

  /// Color de acento de la lista (borde izquierdo).
  final Color accent;

  /// Si no es null, muestra un [StatusChip] a la derecha del título
  /// (solo enfermedades).
  final bool? vigente;

  /// `null` deshabilita la edición al tocar el cuerpo (modo solo lectura).
  final VoidCallback? onTap;

  /// `null` oculta el botón de borrado (modo solo lectura).
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border(left: BorderSide(color: accent, width: 3)),
        boxShadow: AppSpacing.elev1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                          if (vigente != null) ...[
                            const SizedBox(width: AppSpacing.sm),
                            StatusChip(vigente: vigente!),
                          ],
                        ],
                      ),
                      for (final line in subtitles)
                        if (line.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              line,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.colors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: IconButton(
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      color: context.colors.textSecondary,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Eliminar',
                    ),
                  )
                else
                  const SizedBox(width: AppSpacing.xs),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
