import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Pantalla de lista de eventos de salud (US-30).
///
/// Muestra los eventos en orden descendente por fecha.
/// El FAB solo aparece si el usuario tiene el permiso [CodigoPermiso.registrarEventosSalud].
class HealthEventsScreen extends ConsumerWidget {
  const HealthEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosAsync = ref.watch(eventosSaludProvider);
    final puedeAsync = ref.watch(puedeRegistrarEventosSaludProvider);
    final puede = puedeAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Eventos de salud'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: eventosAsync.when(
        loading: () => _EventosSkeleton(),
        error: (err, _) => Center(
          child: InlineErrorBanner(
            message: 'No se pudieron cargar los eventos. $err',
          ),
        ),
        data: (eventos) {
          if (eventos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_outline,
                      size: 64,
                      color: AppColors.textDisabled,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'No hay eventos registrados aún.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (puede)
                      const Text(
                        'Usá el botón + para registrar el primer evento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textDisabled,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            itemCount: eventos.length,
            itemBuilder: (context, i) => HealthEventCard(
              evento: eventos[i],
              onTap: () => context.pushNamed(
                AppRoutes.healthEventDetailName,
                pathParameters: {'id': eventos[i].id.toString()},
              ),
            ),
          );
        },
      ),
      floatingActionButton: puede
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(AppRoutes.healthEventsNewName),
              tooltip: 'Nuevo evento',
              backgroundColor: AppColors.healthAccent,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _EventosSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: List.generate(
          3,
          (i) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}
