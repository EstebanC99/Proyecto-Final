import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Estado que pinta [SummaryHeroCard].
///
/// Es un tipo de presentación, no de dominio: la pantalla que use la card
/// traduce el estado del Resumen inteligente (US 9.16) a una de estas
/// variantes. Así el widget no conoce providers ni entidades y puede
/// conectarse al backend más adelante sin modificarlo.
sealed class SummaryHeroState {
  const SummaryHeroState();
}

/// Hay un resumen disponible para mostrar.
class SummaryHeroContent extends SummaryHeroState {
  const SummaryHeroContent({
    required this.texto,
    this.generadoEn,
    this.pills = const [],
  });

  /// Texto breve del resumen (se recorta a pocas líneas en la card).
  final String texto;

  /// Momento de generación; se muestra como hora corta en el encabezado.
  final DateTime? generadoEn;

  /// Datos de apoyo cortos (ej. "4 de 6 hábitos"). Opcionales.
  final List<String> pills;
}

/// Motivo por el que no hay resumen para mostrar.
enum SummaryHeroEmptyReason {
  /// Todavía no se generó (el Home no dispara la IA).
  noGenerado,

  /// Se generó, pero no había nada que resumir en el día.
  sinDatos,
}

/// No hay resumen para mostrar.
class SummaryHeroEmpty extends SummaryHeroState {
  const SummaryHeroEmpty({this.reason = SummaryHeroEmptyReason.noGenerado});

  final SummaryHeroEmptyReason reason;
}

/// Hero del Resumen inteligente en el Home (US 9.16).
///
/// Bloque destacado con gradiente de marca que adelanta el resumen del día y
/// lleva a la pantalla dedicada mediante [onTapVerCompleto]. Es puramente
/// presentacional: no dispara la generación de IA ni lee providers.
class SummaryHeroCard extends StatelessWidget {
  const SummaryHeroCard({
    super.key,
    required this.state,
    this.delay = Duration.zero,
    this.onTapVerCompleto,
  });

  /// Contenido a mostrar.
  final SummaryHeroState state;

  /// Delay para la animación de entrada. Lo gestiona la pantalla.
  final Duration delay;

  /// Callback del CTA. Si es `null`, la card no es interactiva.
  final VoidCallback? onTapVerCompleto;

  String _formatHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onPrimary;

    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      delay: delay,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: InkWell(
          onTap: onTapVerCompleto,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.colors.primary, context.colors.primaryHover],
              ),
              boxShadow: AppSpacing.elev2,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Encabezado(state: state, onHero: onHero, hora: _hora()),
                  const SizedBox(height: AppSpacing.md),
                  _Cuerpo(state: state, onHero: onHero),
                  if (state case SummaryHeroContent(
                    :final pills,
                  ) when pills.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [for (final pill in pills) _Pill(texto: pill)],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  _Cta(state: state, onHero: onHero),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hora de generación formateada, solo cuando hay contenido con fecha.
  String? _hora() => switch (state) {
    SummaryHeroContent(:final generadoEn) when generadoEn != null =>
      _formatHora(generadoEn),
    _ => null,
  };
}

// ─── Partes internas ─────────────────────────────────────────────────────────

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.state, required this.onHero, this.hora});

  final SummaryHeroState state;
  final Color onHero;
  final String? hora;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: onHero.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.auto_awesome, size: 18, color: onHero),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Resumen del día',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: onHero,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hora != null)
          Text(
            hora!,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: onHero.withValues(alpha: 0.75),
            ),
          ),
      ],
    );
  }
}

class _Cuerpo extends StatelessWidget {
  const _Cuerpo({required this.state, required this.onHero});

  final SummaryHeroState state;
  final Color onHero;

  @override
  Widget build(BuildContext context) {
    final texto = switch (state) {
      SummaryHeroContent(:final texto) => texto,
      SummaryHeroEmpty(reason: SummaryHeroEmptyReason.noGenerado) =>
        'Todavía no generamos tu resumen de hoy.',
      SummaryHeroEmpty(reason: SummaryHeroEmptyReason.sinDatos) =>
        'Nada para resumir todavía: registrá eventos de salud, hábitos o '
            'estados de ánimo del día.',
    };

    return Text(
      texto,
      style: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: onHero.withValues(alpha: 0.94),
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    final onHero = context.colors.onPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: onHero.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onHero,
        ),
      ),
    );
  }
}

class _Cta extends StatelessWidget {
  const _Cta({required this.state, required this.onHero});

  final SummaryHeroState state;
  final Color onHero;

  @override
  Widget build(BuildContext context) {
    final label = switch (state) {
      SummaryHeroContent() => 'Ver resumen completo',
      SummaryHeroEmpty(reason: SummaryHeroEmptyReason.noGenerado) =>
        'Generar resumen',
      SummaryHeroEmpty(reason: SummaryHeroEmptyReason.sinDatos) =>
        'Ver resumen',
    };

    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: onHero.withValues(alpha: 0.18))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: onHero,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.arrow_forward_rounded, size: 18, color: onHero),
        ],
      ),
    );
  }
}
