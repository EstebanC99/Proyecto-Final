import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/wellbeing_alert_catalogs.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import 'wellbeing_observation_row.dart';

/// Banner de "Observaciones de bienestar" del hub de Mi salud (US-36).
///
/// Autocontenido: consulta [alertasBienestarOrdenadasProvider] internamente y
/// no se renderiza (`SizedBox.shrink()`) cuando no hay observaciones o cuando
/// la consulta está cargando/falla (invisibilidad silenciosa, decisión D2).
///
/// Arranca **colapsado** (banner compacto con contador y severidad agregada) y
/// se expande/colapsa in-place con [AnimatedSize] (mismo patrón que
/// [HealthEventsMonthList]). El estado de expansión es presentación local, no
/// persistida, y se reinicia al cambiar de persona de contexto.
class WellbeingObservationsBanner extends ConsumerStatefulWidget {
  const WellbeingObservationsBanner({super.key});

  @override
  ConsumerState<WellbeingObservationsBanner> createState() =>
      _WellbeingObservationsBannerState();
}

class _WellbeingObservationsBannerState
    extends ConsumerState<WellbeingObservationsBanner> {
  bool _expanded = false;

  /// Variante oscurecida del warning para contraste AA sobre fondo claro.
  static const Color _atencionText = Color(0xFF8A6400);

  static const String _disclaimer =
      'Generadas automáticamente a partir de tus registros recientes. '
      'No reemplazan una consulta profesional.';

  @override
  Widget build(BuildContext context) {
    // Reinicia a colapsado al cambiar de persona de contexto (comparando id).
    ref.listen(personaVisualizacionSeleccionadaProvider, (prev, next) {
      final cambioPersona = prev?.value?.id != next.value?.id;
      if (cambioPersona && _expanded) {
        setState(() => _expanded = false);
      }
    });

    final alertas =
        ref.watch(alertasBienestarOrdenadasProvider).value ?? const [];
    if (alertas.isEmpty) return const SizedBox.shrink();

    // Fundido en el lugar (sin desplazamiento): suaviza la aparición cuando el
    // fetch resuelve, sin el slide-down que se percibía como "salto".
    return FadeIn(
      duration: const Duration(milliseconds: 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _card(alertas),
          // Gap fijo hacia el grid, dentro del propio widget: cuando no hay
          // alertas el widget no se renderiza y el gap desaparece con él.
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// Contenedor de la tarjeta (header + contenido animado).
  Widget _card(List<AlertaBienestar> alertas) {
    final hayAtencion = alertas.any(
      (a) => a.severidad == SeveridadesAlertaBienestar.alta,
    );

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppSpacing.elev1,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _expanded
              ? _expandedHeader(alertas.length)
              : _collapsedHeader(alertas, hayAtencion),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _expanded ? _expandedBody(alertas) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Estado colapsado
  // ---------------------------------------------------------------------------

  Widget _collapsedHeader(List<AlertaBienestar> alertas, bool hayAtencion) {
    final total = alertas.length;
    final cantAtencion = alertas
        .where((a) => a.severidad == SeveridadesAlertaBienestar.alta)
        .length;

    // Tratamiento visual segun severidad agregada (decision D1 aplicada al
    // banner colapsado): ambar si hay >= 1 "Atencion", azul si todas informativas.
    final Color fondo = hayAtencion
        ? context.colors.warningContainer
        : context.colors.surface;
    final Color borde = hayAtencion
        ? context.colors.warning
        : context.colors.info;
    final IconData icono = hayAtencion ? Icons.priority_high : Icons.info;

    return Material(
      color: fondo,
      child: InkWell(
        onTap: () => setState(() => _expanded = true),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          decoration: BoxDecoration(
            border: hayAtencion
                ? Border(left: BorderSide(color: borde, width: 3))
                : Border(
                    left: BorderSide(color: borde, width: 3),
                    top: BorderSide(color: context.colors.outline),
                    right: BorderSide(color: context.colors.outline),
                    bottom: BorderSide(color: context.colors.outline),
                  ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Círculo sólido con ícono blanco (más peso visual que una fila).
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: borde, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(icono, size: 16, color: context.colors.onPrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Observaciones de bienestar',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    if (hayAtencion) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.priority_high,
                            size: 14,
                            color: _atencionText,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$cantAtencion de $total '
                            '${cantAtencion == 1 ? "requiere" : "requieren"} atención',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _atencionText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _counterBadge(total),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: context.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Estado expandido
  // ---------------------------------------------------------------------------

  Widget _expandedHeader(int total) {
    return Material(
      color: context.colors.surface,
      child: InkWell(
        onTap: () => setState(() => _expanded = false),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.visibility,
                  size: 18,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Observaciones de bienestar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _counterBadge(total),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: context.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _expandedBody(List<AlertaBienestar> alertas) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _disclaimer,
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Ya vienen ordenadas (Atención primero): no se reordena aquí.
          for (final alerta in alertas) ...[
            WellbeingObservationRow(
              alerta: alerta,
              onTap: () => _onRowTap(alerta),
            ),
            if (alerta != alertas.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navegación por fila (según categoría, no según tipo)
  // ---------------------------------------------------------------------------

  void _onRowTap(AlertaBienestar alerta) {
    if (alerta.categoria == CategoriasAlertaBienestar.habito) {
      final habitoId = alerta.habitoVidaId;
      // Guarda defensiva: sin id no se puede navegar al detalle del hábito.
      if (habitoId == null) return;
      context.pushNamed(
        AppRoutes.healthHabitDetailName,
        pathParameters: {'id': habitoId.toString()},
      );
    } else {
      context.pushNamed(AppRoutes.healthMoodHistoryName);
    }
  }

  // ---------------------------------------------------------------------------
  // Badge de contador (mismo estilo que health-section-badge de Ficha de salud)
  // ---------------------------------------------------------------------------

  Widget _counterBadge(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        '$total',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.colors.textSecondary,
        ),
      ),
    );
  }
}
