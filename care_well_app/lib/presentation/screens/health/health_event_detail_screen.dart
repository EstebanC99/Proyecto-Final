import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// Detalle de un evento de salud con header tipado y notas del equipo (US-32).
///
/// Las notas vienen embebidas en el evento (derivadas de
/// [notasByEventoProvider]). Los usuarios con permiso pueden agregar, editar y
/// eliminar notas.
class HealthEventDetailScreen extends ConsumerWidget {
  const HealthEventDetailScreen({super.key, required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventoAsync = ref.watch(eventoSaludByIdProvider(eventId));
    final notas = ref.watch(notasByEventoProvider(eventId));
    final puede =
        ref.watch(puedeRegistrarEventosSaludProvider).valueOrNull ?? false;

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
          error: (_, _) => const Text('Evento'),
        ),
        actions: [
          if (puede)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: AppColors.error,
              tooltip: 'Eliminar evento',
              onPressed: () async {
                final eliminado = await ConfirmDialog.show(
                  context,
                  title: '¿Eliminar este evento de salud?',
                  body:
                      'El evento y todas sus notas se eliminarán de forma definitiva.',
                  confirmLabel: 'Eliminar',
                  icon: Icons.delete_outline,
                  onConfirm: () async {
                    await ref.read(eliminarEventoSaludProvider)(
                      eventoId: eventId,
                    );
                  },
                );
                // El diálogo ya cerró su propia página; navegamos con
                // go_router a la lista para no vaciar el stack (evita el pop
                // duplicado que dejaba la pantalla en negro).
                if (eliminado && context.mounted) {
                  context.go(AppRoutes.healthEvents);
                }
              },
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

          return CustomScrollView(
            slivers: [
              // ── Header del evento ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: _EventHeaderCard(evento: evento),
                ),
              ),

              // ── Encabezado de sección de notas ──────────────────────────
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

              // ── Notas ────────────────────────────────────────────────────
              if (notas.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 36,
                            color: AppColors.textDisabled,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'Aún no hay notas. Agregá la primera.',
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
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.xxxl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final nota = notas[i];
                      return NoteCard(
                        nota: nota,
                        onEdit: puede
                            ? (nuevoContenido) =>
                                  ref.read(modificarNotaEventoProvider)(
                                    eventoSaludId: eventId,
                                    notaId: nota.id,
                                    contenido: nuevoContenido,
                                  )
                            : null,
                        onDelete: puede
                            ? () => ref.read(eliminarNotaEventoProvider)(
                                eventoSaludId: eventId,
                                notaId: nota.id,
                              )
                            : null,
                      );
                    }, childCount: notas.length),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: puede
          ? FloatingActionButton(
              onPressed: () => context.pushNamed(
                AppRoutes.healthEventNoteNewName,
                pathParameters: {'id': eventId.toString()},
              ),
              tooltip: 'Agregar nota',
              backgroundColor: AppColors.healthAccent,
              child: const Icon(Icons.note_add, color: Colors.white),
            )
          : null,
    );
  }
}

// ─── Header del evento ────────────────────────────────────────────────────────

/// Card de presentación del evento en el detalle.
class _EventHeaderCard extends StatelessWidget {
  const _EventHeaderCard({required this.evento});

  final EventoDeSalud evento;

  @override
  Widget build(BuildContext context) {
    final fechaStr = DateFormat(
      "d 'de' MMMM 'de' yyyy · HH:mm",
      'es',
    ).format(evento.fechaHora);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: AppSpacing.elev1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila: chip de tipo + fecha
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HealthEventTypeChip(tipo: evento.tipo),
              const Spacer(),
              Text(
                fechaStr,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDisabled,
                ),
              ),
            ],
          ),
          // Badge "Desde agenda"
          if (evento.fechaOcurrenciaEventoAgenda != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_available_outlined,
                    size: 13,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Generado desde la agenda',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Descripción completa
          Text(
            evento.descripcion,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
