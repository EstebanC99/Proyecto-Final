import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Hub principal del módulo Mi salud (US-28 a US-33).
///
/// Muestra tarjetas de acceso rápido a cada sub-módulo de salud:
/// Hábitos, Ficha de salud, Eventos y Estado de ánimo.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaAsync = ref.watch(personaVisualizacionSeleccionadaProvider);
    final puedeVerFichaAsync = ref.watch(puedeVerSaludProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Salud'),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector de persona de contexto
          personaAsync.when(
            data: (persona) => persona != null
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: ContextSelector(),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
          Expanded(
            child: personaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: InlineErrorBanner(
                  message: 'No se pudo cargar el módulo salud. $err',
                ),
              ),
              data: (persona) {
                if (persona == null) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Observaciones de bienestar (US-36): autocontenido,
                      // no ocupa espacio (ni gap) cuando no hay alertas.
                      const WellbeingObservationsBanner(),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.9,
                        children: [
                          HealthCategoryCard(
                            icon: Icons.self_improvement,
                            accentColor: context.colors.habitsAccent,
                            label: 'Hábitos de vida',
                            description:
                                'Rutinas diarias aconsejables para el bienestar de la persona.',
                            onTap: () =>
                                context.pushNamed(AppRoutes.healthHabitsName),
                          ),
                          HealthCategoryCard(
                            icon: Icons.medical_services_outlined,
                            accentColor: context.colors.healthAccent,
                            label: 'Ficha de salud',
                            description:
                                'Datos clínicos: factor sanguíneo, antecedentes, alergias y enfermedades.',
                            enabled: puedeVerFichaAsync.value ?? false,
                            loading: puedeVerFichaAsync.isLoading,
                            onTap: () =>
                                context.pushNamed(AppRoutes.healthRecordName),
                          ),
                          HealthCategoryCard(
                            icon: Icons.event_note_outlined,
                            accentColor: const Color(0xFF0284C7),
                            label: 'Eventos de salud',
                            description:
                                'Eventos esporádicos que ocurrieron sin anticipación y deben registrarse.',
                            onTap: () =>
                                context.pushNamed(AppRoutes.healthEventsName),
                          ),
                          HealthCategoryCard(
                            icon: Icons.mood,
                            accentColor: context.colors.moodAccent,
                            label: 'Estado de ánimo',
                            description:
                                'Registro periódico del bienestar emocional',
                            onTap: () =>
                                context.pushNamed(AppRoutes.healthMoodNewName),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FullWidthActionTile(
                        icon: Icons.timeline,
                        label: 'Línea de tiempo',
                        color: context.colors.healthAccent,
                        onTap: () =>
                            context.pushNamed(AppRoutes.healthTimelineName),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
