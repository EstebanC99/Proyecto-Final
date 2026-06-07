import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Hub principal del módulo Mi salud (US-28 a US-33).
///
/// Muestra tarjetas de acceso rápido a cada sub-módulo de salud:
/// Hábitos, Recomendaciones, Eventos, Línea de tiempo y Estado de ánimo.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaAsync = ref.watch(healthPersonaContextProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Salud'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Primero agregá una persona a cargo para ver Salud.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
                }
                return GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.9,
                  children: [
                    HealthCategoryCard(
                      icon: Icons.self_improvement,
                      accentColor: AppColors.habitsAccent,
                      label: 'Hábitos de vida',
                      description: 'Alimentación, ejercicio, sueño y bienestar',
                      onTap: () =>
                          context.pushNamed(AppRoutes.healthHabitsName),
                    ),
                    HealthCategoryCard(
                      icon: Icons.medical_services_outlined,
                      accentColor: AppColors.healthAccent,
                      label: 'Recomendaciones',
                      description: 'Pautas personalizadas del equipo médico',
                      onTap: () => context.pushNamed(
                        AppRoutes.healthRecommendationsName,
                      ),
                    ),
                    HealthCategoryCard(
                      icon: Icons.event_note_outlined,
                      accentColor: const Color(0xFF0284C7),
                      label: 'Eventos de salud',
                      description: 'Citas, tratamientos y novedades clínicas',
                      onTap: () =>
                          context.pushNamed(AppRoutes.healthEventsName),
                    ),
                    HealthCategoryCard(
                      icon: Icons.timeline,
                      accentColor: const Color(0xFF059669),
                      label: 'Línea de tiempo',
                      description: 'Evolución cronológica de la salud',
                      onTap: () =>
                          context.pushNamed(AppRoutes.healthTimelineName),
                    ),
                    HealthCategoryCard(
                      icon: Icons.mood,
                      accentColor: AppColors.moodAccent,
                      label: 'Estado de ánimo',
                      description: 'Registro periódico del bienestar emocional',
                      onTap: () =>
                          context.pushNamed(AppRoutes.healthMoodNewName),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
