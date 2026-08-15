import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Pill de un hábito dentro del Resumen (US 9.16).
///
/// Completado: fondo [AppPalette.habitsContainer] y tick relleno. Pendiente:
/// fondo [AppPalette.surfaceVariant] y anillo vacío. El texto va siempre en un
/// color con contraste suficiente (el acento se reserva para el tick), para que
/// la pill siga siendo legible en ambos temas.
class SummaryHabitChip extends StatelessWidget {
  const SummaryHabitChip({super.key, required this.habito});

  final HabitoResumen habito;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final completado = habito.completado;

    return Semantics(
      label:
          '${habito.descripcion}, ${completado ? 'completado' : 'pendiente'}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: completado ? colors.habitsContainer : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            completado
                ? _Tick(color: colors.habitsAccent)
                : const _AnilloVacio(),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                habito.descripcion,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: completado ? colors.textPrimary : colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Círculo relleno con el check de hábito cumplido.
///
/// El check usa `onPrimary` prestado: la paleta no tiene un `onHabits` y este
/// es hoy el único caso. Funciona porque en ambos temas contrasta con
/// `habitsAccent` (blanco sobre el naranja del tema claro, casi negro sobre el
/// naranja claro del oscuro). Si aparece un segundo uso, agregar el token.
class _Tick extends StatelessWidget {
  const _Tick({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(Icons.check, size: 11, color: context.colors.onPrimary),
    );
  }
}

/// Anillo vacío de hábito pendiente.
class _AnilloVacio extends StatelessWidget {
  const _AnilloVacio();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.textDisabled, width: 1.8),
      ),
    );
  }
}
