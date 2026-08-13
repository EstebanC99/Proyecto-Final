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
        ref.invalidate(resumenSaludProvider);
        await ref.read(resumenSaludProvider.future);
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

/// Card destacada de la ficha.
///
/// Los chips de resumen se muestran a cualquier miembro del equipo: son datos
/// agregados, sin detalle clínico. El permiso sólo bloquea la navegación a la
/// ficha completa (candado, card atenuada y sin tap).
class _FichaSaludCard extends ConsumerWidget {
  const _FichaSaludCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puedeVerAsync = ref.watch(puedeVerSaludProvider);
    final puedeVer = puedeVerAsync.value ?? false;

    final resumen = _resumen(ref);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: HealthRecordHighlightCard(
        enabled: puedeVer,
        loading: puedeVerAsync.isLoading,
        datosDisponibles: resumen?.tieneFicha ?? false,
        factorSanguineo: resumen?.grupoSanguineo,
        cantidadAlergias: resumen?.cantidadAlergias ?? 0,
        cantidadEnfermedades: resumen?.cantidadEnfermedades ?? 0,
        cantidadAntecedentes: resumen?.cantidadAntecedentes ?? 0,
        onTap: () => context.pushNamed(AppRoutes.healthRecordName),
      ),
    );
  }
}

/// Resumen ya resuelto, o `null` si todavía carga o falló.
///
/// Cada tarjeta degrada por su cuenta: sin resumen se dibuja sin métrica, nunca
/// un error a pantalla completa.
ResumenSalud? _resumen(WidgetRef ref) =>
    switch (ref.watch(resumenSaludProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };

// ─── Hábitos ──────────────────────────────────────────────────────────────────

class _HabitosCard extends ConsumerWidget {
  const _HabitosCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumen = _resumen(ref);
    final hayHabitos = resumen?.tieneHabitos ?? false;

    return HealthMetricCard(
      icon: Icons.self_improvement,
      accentColor: context.colors.habitsAccent,
      containerColor: context.colors.habitsContainer,
      label: 'Hábitos de vida',
      metricValue: hayHabitos
          ? '${resumen!.cantidadHabitosCompletados ?? 0} de '
                '${resumen.cantidadHabitos}'
          : null,
      metricSuffix: resumen == null
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
    final resumen = _resumen(ref);
    // El resumen manda sólo el id del estado: la descripción y el emoji salen
    // del catálogo local, espejo del de backend.
    final animoId = resumen?.estadoAnimoId;
    final descripcion = animoId == null ? null : moodLabelForLevel(animoId);

    return HealthMetricCard(
      icon: Icons.mood,
      accentColor: context.colors.moodAccent,
      containerColor: context.colors.moodContainer,
      label: 'Estado de ánimo',
      metricPrefix: 'Hoy: ',
      metricValue: descripcion == null
          ? null
          : '${moodEmojiForLevel(animoId!)} $descripcion',
      metricSuffix: resumen != null && descripcion == null
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
    final resumen = _resumen(ref);
    final hayEvento = resumen?.tieneEventos ?? false;

    return HealthMetricCard(
      icon: Icons.event_note_outlined,
      accentColor: context.colors.info,
      containerColor: context.colors.infoContainer,
      label: 'Eventos de salud',
      layout: HealthMetricCardLayout.wide,
      metricPrefix: 'Último: ',
      metricValue: hayEvento
          ? textoRelativoEnDias(resumen!.diasDesdeUltimoEvento ?? 0)
          : null,
      metricSuffix: hayEvento
          ? ' · ${resumen!.ultimoEventoSalud}'
          : (resumen != null ? 'Sin eventos registrados' : null),
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
