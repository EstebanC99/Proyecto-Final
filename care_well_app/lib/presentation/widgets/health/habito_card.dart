import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import 'tipo_habito_theme.dart';

/// Card de un hábito de vida dentro del listado diario.
///
/// El cuerpo lleva al detalle del hábito; el círculo de la derecha marca o
/// desmarca la realización del día sin salir de la lista.
class HabitoCard extends StatelessWidget {
  const HabitoCard({
    super.key,
    required this.habito,
    required this.onTap,
    this.onToggleRealizacion,
  });

  final HabitoVida habito;

  /// Navegación al detalle del hábito.
  final VoidCallback onTap;

  /// Marca/desmarca la realización del día. Si es `null` el check se muestra
  /// igual pero no es accionable (el usuario no es miembro activo del equipo).
  final VoidCallback? onToggleRealizacion;

  @override
  Widget build(BuildContext context) {
    final realizado = habito.realizacion != null;
    final acento = TipoHabitoTheme.accentFor(context, habito.tipo.id);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: realizado
            ? context.colors.surfaceVariant
            : context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppSpacing.elev1,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TipoHabitoTheme.containerFor(
                      context,
                      habito.tipo.id,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    TipoHabitoTheme.iconFor(habito.tipo.id),
                    size: 20,
                    color: acento,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habito.tipo.descripcion.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: acento,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        habito.descripcion,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: realizado
                              ? context.colors.textSecondary
                              : context.colors.textPrimary,
                          decoration: realizado
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: context.colors.outline,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _CheckCircle(
                  key: ValueKey('habito-check-${habito.id}'),
                  realizado: realizado,
                  descripcion: habito.descripcion,
                  onTap: onToggleRealizacion,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Círculo de estado de realización, centrado en un área táctil de 48 dp.
class _CheckCircle extends StatelessWidget {
  const _CheckCircle({
    super.key,
    required this.realizado,
    required this.descripcion,
    this.onTap,
  });

  final bool realizado;
  final String descripcion;
  final VoidCallback? onTap;

  /// Diámetro del círculo visible (el área táctil es mayor).
  static const double _diametro = 30;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: realizado,
      label: 'Marcar $descripcion como realizado',
      child: SizedBox(
        width: AppSpacing.minTapTarget,
        height: AppSpacing.minTapTarget,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: _diametro,
                height: _diametro,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: realizado ? context.colors.primary : null,
                  border: realizado
                      ? null
                      : Border.all(color: context.colors.outline, width: 2),
                ),
                child: realizado
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: context.colors.onPrimary,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
