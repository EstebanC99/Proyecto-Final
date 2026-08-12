import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Hub principal del módulo Mi salud (US-28 a US-33).
///
/// Reúne los accesos a cada submódulo (ficha, hábitos, ánimo y eventos) y
/// resume el estado del día: cada tarjeta muestra su propia métrica y degrada
/// sola —se dibuja sin métrica— si su fuente todavía carga o falla. Ningún
/// error de una métrica tumba la pantalla.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: const ContextAppBar(eyebrow: 'Salud'),
      body: personaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: InlineErrorBanner(
            message: 'No se pudo cargar el módulo salud. $err',
          ),
        ),
        data: (persona) {
          if (persona == null) return const _SinPersonaDeContexto();
          return const _HealthHubBody();
        },
      ),
    );
  }
}

// ─── Cuerpo del hub ───────────────────────────────────────────────────────────

class _HealthHubBody extends ConsumerWidget {
  const _HealthHubBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: context.colors.healthAccent,
      onRefresh: () async {
        ref
          ..invalidate(fichaSaludProvider)
          ..invalidate(habitosProvider)
          ..invalidate(animoHoyProvider)
          ..invalidate(ultimoEventoSaludProvider);
        await ref.read(habitosProvider.future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Observaciones de bienestar (US-36): autocontenido,
            // no ocupa espacio (ni gap) cuando no hay alertas.
            const WellbeingObservationsBanner(),
            const _FichaSaludCard(),
            const SectionLabel(text: 'Seguimiento'),
            // Dos tarjetas de igual altura: la fija el contenido más alto, así
            // no desbordan con escalas tipográficas grandes.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(child: _HabitosCard()),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: _AnimoCard()),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const _EventosCard(),
            const SizedBox(height: AppSpacing.lg),
            FullWidthActionTile(
              icon: Icons.timeline,
              label: 'Ver línea de tiempo',
              color: context.colors.primary,
              style: FullWidthActionTileStyle.filled,
              delay: const Duration(milliseconds: 180),
              onTap: () => context.pushNamed(AppRoutes.healthTimelineName),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Ficha de salud ───────────────────────────────────────────────────────────

/// Card destacada de la ficha, gateada por permiso.
///
/// La consulta de la ficha sólo se dispara cuando el permiso ya resolvió que
/// se puede ver: así el hub no provoca un 403 para quien no tiene acceso.
class _FichaSaludCard extends ConsumerWidget {
  const _FichaSaludCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puedeVerAsync = ref.watch(puedeVerSaludProvider);
    final puedeVer = puedeVerAsync.value ?? false;

    final fichaAsync = puedeVer ? ref.watch(fichaSaludProvider) : null;
    final ficha = switch (fichaAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final fichaResuelta = fichaAsync is AsyncData;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: HealthRecordHighlightCard(
        enabled: puedeVer,
        loading: puedeVerAsync.isLoading,
        datosDisponibles: fichaResuelta,
        factorSanguineo: ficha?.factorSanguineo,
        cantidadAlergias: ficha?.alergias.length ?? 0,
        cantidadEnfermedades: ficha?.enfermedades.length ?? 0,
        cantidadAntecedentes: ficha?.antecedentes.length ?? 0,
        onTap: () => context.pushNamed(AppRoutes.healthRecordName),
      ),
    );
  }
}

// ─── Hábitos ──────────────────────────────────────────────────────────────────

class _HabitosCard extends ConsumerWidget {
  const _HabitosCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progreso = switch (ref.watch(progresoHabitosHoyProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final hayHabitos = progreso != null && progreso.total > 0;

    return HealthMetricCard(
      icon: Icons.self_improvement,
      accentColor: context.colors.habitsAccent,
      containerColor: context.colors.habitsContainer,
      label: 'Hábitos de vida',
      metricValue: hayHabitos
          ? '${progreso.completados} de ${progreso.total}'
          : null,
      metricSuffix: progreso == null
          ? null
          : (hayHabitos ? ' completados hoy' : 'Sin hábitos cargados'),
      onTap: () => context.pushNamed(AppRoutes.healthHabitsName),
    );
  }
}

// ─── Estado de ánimo ──────────────────────────────────────────────────────────

class _AnimoCard extends ConsumerWidget {
  const _AnimoCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animoAsync = ref.watch(animoHoyProvider);
    final PersonaEstadoAnimo? animo = switch (animoAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return HealthMetricCard(
      icon: Icons.mood,
      accentColor: context.colors.moodAccent,
      containerColor: context.colors.moodContainer,
      label: 'Estado de ánimo',
      metricPrefix: 'Hoy: ',
      metricValue: animo == null
          ? null
          : '${moodEmoji(animo.estado)} ${animo.estado.descripcion}',
      metricSuffix: animoAsync is AsyncData && animo == null
          ? 'Sin registro hoy'
          : null,
      delay: const Duration(milliseconds: 60),
      onTap: () => context.pushNamed(AppRoutes.healthMoodNewName),
    );
  }
}

// ─── Eventos de salud ─────────────────────────────────────────────────────────

class _EventosCard extends ConsumerWidget {
  const _EventosCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventoAsync = ref.watch(ultimoEventoSaludProvider);
    final EventoSalud? evento = switch (eventoAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };

    return HealthMetricCard(
      icon: Icons.event_note_outlined,
      accentColor: context.colors.info,
      containerColor: context.colors.infoContainer,
      label: 'Eventos de salud',
      layout: HealthMetricCardLayout.wide,
      metricPrefix: 'Último: ',
      metricValue: evento == null ? null : textoRelativoDesde(evento.fechaHora),
      metricSuffix: evento != null
          ? ' · ${evento.tipo.descripcion}'
          : (eventoAsync is AsyncData ? 'Sin eventos registrados' : null),
      delay: const Duration(milliseconds: 120),
      onTap: () => context.pushNamed(AppRoutes.healthEventsName),
    );
  }
}

// ─── Estado sin persona ───────────────────────────────────────────────────────

class _SinPersonaDeContexto extends StatelessWidget {
  const _SinPersonaDeContexto();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Text(
          'Primero agregá una persona a cargo para ver Salud.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: context.colors.textSecondary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
