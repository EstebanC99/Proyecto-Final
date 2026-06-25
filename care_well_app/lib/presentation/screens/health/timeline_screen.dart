import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Línea de tiempo cronológica de eventos de salud (US-33).
///
/// Orden ascendente: más antiguo arriba, más reciente abajo.
/// El último tile no muestra línea conectora.
class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventosSinOrden = ref.watch(eventosSaludProvider);
    final personaAsync = ref.watch(healthPersonaContextProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Línea de tiempo'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          personaAsync.when(
            data: (persona) => persona != null
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: Chip(
                      label: Text(
                        '${persona.nombre} ${persona.apellido}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.healthAccent,
                        ),
                      ),
                      backgroundColor: AppColors.healthContainer,
                      padding: EdgeInsets.zero,
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: eventosSinOrden.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: InlineErrorBanner(
            message: 'No se pudo cargar la línea de tiempo. $err',
          ),
        ),
        data: (eventosDesc) {
          // Orden ascendente para la timeline (el más viejo arriba)
          final eventos = [...eventosDesc]
            ..sort((a, b) => a.fecha.compareTo(b.fecha));

          if (eventos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_outline,
                      size: 48,
                      color: AppColors.textDisabled,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Aun no hay eventos registrados.',
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

          return RefreshIndicator(
            color: AppColors.healthAccent,
            onRefresh: () async => ref.invalidate(eventosSaludProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              itemCount: eventos.length,
              itemBuilder: (context, i) => TimelineTile(
                evento: eventos[i],
                isLast: i == eventos.length - 1,
                onTap: () => context.pushNamed(
                  AppRoutes.healthEventDetailName,
                  pathParameters: {'id': eventos[i].id.toString()},
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
