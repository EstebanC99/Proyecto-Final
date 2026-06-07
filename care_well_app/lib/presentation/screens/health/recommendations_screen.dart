import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de recomendaciones médicas (US-29).
///
/// Solo lectura. Siempre muestra el [HealthDisclaimerBanner] al tope.
class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recomendacionesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recomendaciones'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: recsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: InlineErrorBanner(
            message: 'No se pudieron cargar las recomendaciones. $err',
          ),
        ),
        data: (recs) => CustomScrollView(
          slivers: [
            // Banner de disclaimer siempre primero
            const SliverToBoxAdapter(child: HealthDisclaimerBanner()),

            if (recs.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.healing_outlined,
                          size: 48,
                          color: AppColors.textDisabled,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Todavía no hay suficientes datos para generar '
                          'recomendaciones. Seguí registrando hábitos y '
                          'eventos de salud.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => RecommendationCard(recomendacion: recs[i]),
                    childCount: recs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
