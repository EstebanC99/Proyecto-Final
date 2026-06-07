import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Detalle de un evento de salud con notas del equipo (US-32).
class HealthEventDetailScreen extends ConsumerWidget {
  const HealthEventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventoAsync = ref.watch(eventoSaludByIdProvider(eventId));
    final notasAsync = ref.watch(notasByEventoProvider(eventId));
    final puedeAsync = ref.watch(puedeRegistrarEventosSaludProvider);
    final puede = puedeAsync.valueOrNull ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: eventoAsync.when(
          data: (e) => Text(
            e?.descripcion.split('.').first ?? 'Detalle del evento',
            overflow: TextOverflow.ellipsis,
          ),
          loading: () => const Text('Cargando...'),
          error: (e, st) => const Text('Evento'),
        ),
        actions: [
          if (puede)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              tooltip: 'Eliminar evento',
              onPressed: () => ConfirmDialog.show(
                context,
                title: '¿Eliminar este evento de salud?',
                body:
                    'El evento y sus notas se eliminarán de forma definitiva y no podrán recuperarse.',
                confirmLabel: 'Eliminar',
                onConfirm: () async {
                  await ref.read(eliminarEventoSaludProvider)(
                    eventoId: eventId,
                  );
                  if (context.mounted && context.canPop()) context.pop();
                },
              ),
            ),
        ],
      ),
      body: eventoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: InlineErrorBanner(
            message: 'No se pudo cargar el evento. $err',
          ),
        ),
        data: (evento) {
          if (evento == null) {
            return const Center(child: Text('Evento no encontrado.'));
          }

          final fechaStr = DateFormat(
            'd \'de\' MMMM \'de\' yyyy',
            'es',
          ).format(evento.fecha);

          return CustomScrollView(
            slivers: [
              // Card del evento
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      boxShadow: AppSpacing.elev1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fechaStr,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          evento.descripcion,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (evento.notas != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            evento.notas!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Encabezado de notas
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Text(
                    'NOTAS DEL EQUIPO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Notas
              notasAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: InlineErrorBanner(
                      message: 'No se pudieron cargar las notas. $err',
                    ),
                  ),
                ),
                data: (notas) {
                  if (notas.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 32,
                                color: AppColors.textDisabled,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'Aun no hay notas. Agregá la primera.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textDisabled,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => NoteCard(nota: notas[i]),
                        childCount: notas.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: puede
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(
                AppRoutes.healthEventNoteNewName,
                pathParameters: {'id': eventId},
              ),
              tooltip: 'Agregar nota',
              backgroundColor: AppColors.healthAccent,
              child: const Icon(Icons.note_add, color: Colors.white),
            )
          : null,
    );
  }
}
