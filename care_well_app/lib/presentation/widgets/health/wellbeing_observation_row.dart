import 'package:flutter/material.dart';

import '../../../config/constraints/wellbeing_alert_catalogs.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';

/// Fila de una observación de bienestar dentro de la lista expandida (US-36).
///
/// El nivel visual (Atención / Informativa) se deriva de [AlertaBienestar.severidad]
/// según el mapeo de presentación D1: `alta` -> "Atención", `media`/`baja` ->
/// "Informativa". La categoría (ánimo / hábito) define el ícono y el color de
/// acento del círculo. El mensaje se muestra completo, sin truncar.
class WellbeingObservationRow extends StatelessWidget {
  const WellbeingObservationRow({
    super.key,
    required this.alerta,
    required this.onTap,
  });

  final AlertaBienestar alerta;
  final VoidCallback onTap;

  /// Variante oscurecida del warning para cumplir contraste AA sobre el
  /// contenedor claro (mismo criterio que [StatusChip] de Ficha de salud).
  static const Color _atencionText = Color(0xFF8A6400);

  bool get _esAtencion => alerta.severidad == SeveridadesAlertaBienestar.alta;

  bool get _esAnimo => alerta.categoria == CategoriasAlertaBienestar.animo;

  @override
  Widget build(BuildContext context) {
    // Severidad -> fondo, borde y color de etiqueta.
    final Color fondo = _esAtencion
        ? AppColors.warningContainer
        : AppColors.surface;
    final Color bordeIzq = _esAtencion ? AppColors.warning : AppColors.info;
    final Color severidadColor = _esAtencion ? _atencionText : AppColors.info;
    final IconData severidadIcon = _esAtencion
        ? Icons.priority_high
        : Icons.info_outline;
    final String severidadLabel = _esAtencion ? 'ATENCIÓN' : 'INFORMATIVA';

    // Categoría -> círculo tenue + ícono de acento.
    final Color categoriaBg = _esAnimo
        ? AppColors.moodContainer
        : AppColors.habitsContainer;
    final Color categoriaFg = _esAnimo
        ? AppColors.moodAccent
        : AppColors.habitsAccent;
    final IconData categoriaIcon = _esAnimo ? Icons.mood : Icons.directions_run;

    // Radio compartido por las tres capas de decoración.
    const radius = BorderRadius.all(Radius.circular(AppSpacing.radiusMd));

    // Contorno neutro 1px (solo Informativa) en top/right/bottom. Va en una capa
    // externa, separado del acento izquierdo, porque Flutter no permite
    // borderRadius sobre un Border con colores no uniformes: al separarlos, cada
    // Border queda con un único color visible (camino soportado por el framework,
    // que además pinta el borde siguiendo las esquinas redondeadas).
    final Border? outlineBorder = _esAtencion
        ? null
        : const Border(
            top: BorderSide(color: AppColors.outline),
            right: BorderSide(color: AppColors.outline),
            bottom: BorderSide(color: AppColors.outline),
          );

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, border: outlineBorder),
      child: Material(
        color: fondo,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppSpacing.minTapTarget,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              // Acento izquierdo 3px (un único color visible -> radio-safe).
              border: Border(left: BorderSide(color: bordeIzq, width: 3)),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Círculo de categoría (28dp).
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: categoriaBg,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(categoriaIcon, size: 16, color: categoriaFg),
                ),
                const SizedBox(width: AppSpacing.md),
                // Contenido: etiqueta de severidad + mensaje.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(severidadIcon, size: 14, color: severidadColor),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            severidadLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: severidadColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        alerta.mensaje,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Affordance de navegación, alineado al centro del círculo.
                const SizedBox(
                  height: 28,
                  child: Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
