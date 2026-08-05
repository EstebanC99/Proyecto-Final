import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Encabezado de navegación mensual para la pantalla de agenda.
///
/// Muestra el mes y año actual (p. ej. "Julio 2026") con flechas ‹ › para
/// moverse entre meses. Las flechas tienen un área táctil mínima de 48 dp
/// para cumplir con los requisitos de accesibilidad.
///
/// Este widget es completamente presentacional: no gestiona estado propio.
/// El estado del mes actual lo mantiene la pantalla contenedora.
class MonthNavHeader extends StatelessWidget {
  const MonthNavHeader({
    super.key,
    required this.mes,
    required this.onPrevious,
    required this.onNext,
  });

  /// Mes que se visualiza actualmente (solo se usan año y mes).
  final DateTime mes;

  /// Callback al presionar la flecha izquierda (mes anterior).
  final VoidCallback onPrevious;

  /// Callback al presionar la flecha derecha (mes siguiente).
  ///
  /// Si es `null`, la flecha se muestra deshabilitada (p. ej. para impedir
  /// navegar a meses futuros).
  final VoidCallback? onNext;

  static const _nombresMes = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  String get _etiqueta => '${_nombresMes[mes.month - 1]} ${mes.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          bottom: BorderSide(color: context.colors.outline, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          _ArrowButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Mes anterior',
            onTap: onPrevious,
          ),
          Expanded(
            child: Center(
              child: Text(
                _etiqueta,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          _ArrowButton(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Mes siguiente',
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

// ─── Botón de flecha ──────────────────────────────────────────────────────────

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final habilitado = onTap != null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: SizedBox(
          width: AppSpacing.minTapTarget,
          height: AppSpacing.minTapTarget,
          child: Icon(
            icon,
            size: 28,
            color: habilitado
                ? context.colors.primary
                : context.colors.textDisabled,
          ),
        ),
      ),
    );
  }
}
