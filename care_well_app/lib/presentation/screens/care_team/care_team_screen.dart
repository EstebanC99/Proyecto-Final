import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-16 · Visualización del equipo de cuidado.
///
/// Muestra responsables y cuidadores asociados a la persona de contexto.
/// El chip de contexto indica de quién es el equipo.
class CareTeamScreen extends ConsumerWidget {
  const CareTeamScreen({super.key});

  /// Muestra el bottom sheet para seleccionar qué tipo de miembro agregar.
  void _mostrarSelectorAlta(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle visual
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Agregar al equipo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Agregar responsable'),
            subtitle: const Text('Gestiona datos y administra el equipo'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(AppRoutes.careTeamAddResponsibleName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.volunteer_activism_outlined),
            title: const Text('Agregar cuidador'),
            subtitle: const Text('Realiza tareas de cuidado según permisos'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(AppRoutes.careTeamAddCaregiverName);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaCtxAsync = ref.watch(careTeamContextPersonaProvider);
    final puedeAdministrarAsync = ref.watch(puedeAdministrarEquipoProvider);
    final usuario = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Equipo de cuidado'),
        actions: [
          puedeAdministrarAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (puede) => puede
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                        tooltip: 'Agregar miembro',
                        onPressed: () => _mostrarSelectorAlta(context),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: personaCtxAsync.when(
        loading: () => const _SkeletonTeam(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: InlineErrorBanner(message: 'No se pudo cargar el equipo.'),
        ),
        data: (personaCtx) {
          if (personaCtx == null) {
            return const _EmptyNoPersonas();
          }
          return _TeamBody(
            personaCtx: personaCtx,
            usuarioId: usuario?.persona.id ?? 0,
          );
        },
      ),
      floatingActionButton: puedeAdministrarAsync.maybeWhen(
        data: (puede) => puede
            ? FloatingActionButton(
                onPressed: () => _mostrarSelectorAlta(context),
                backgroundColor: AppColors.primary,
                tooltip: 'Agregar miembro',
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

// ─── Cuerpo del equipo ────────────────────────────────────────────────────────

class _TeamBody extends ConsumerWidget {
  const _TeamBody({required this.personaCtx, required this.usuarioId});

  final Persona personaCtx;
  final int usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asignacionesAsync = ref.watch(
      careTeamAssignmentsProvider(personaCtx.id),
    );
    final puedeAdministrar =
        ref.watch(puedeAdministrarEquipoProvider).valueOrNull ?? false;
    final esResponsable = ref.watch(esResponsableProvider).valueOrNull ?? false;

    return asignacionesAsync.when(
      loading: () => const _SkeletonTeam(),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: InlineErrorBanner(message: 'No se pudo cargar el equipo.'),
      ),
      data: (asignaciones) {
        final responsables = asignaciones
            .where(
              (a) =>
                  a.rol.id == RolesCuidadoConst.responsable &&
                  a.estado.id == EstadosAsignacionConst.activa,
            )
            .toList();
        final cuidadores = asignaciones
            .where(
              (a) =>
                  a.rol.id == RolesCuidadoConst.cuidador &&
                  a.estado.id == EstadosAsignacionConst.activa,
            )
            .toList();
        final pendientes = asignaciones
            .where((a) => a.estado.id == EstadosAsignacionConst.pendiente)
            .toList();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(careTeamAssignmentsProvider(personaCtx.id));
            await ref.read(careTeamAssignmentsProvider(personaCtx.id).future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              88,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de contexto
                const SizedBox(height: AppSpacing.lg),
                const ContextSelector(),
                const SizedBox(height: AppSpacing.lg),

                // Solicitudes pendientes (solo Responsables, si hay alguna).
                if (esResponsable && pendientes.isNotEmpty) ...[
                  _SectionHeader('SOLICITUDES PENDIENTES'),
                  const SizedBox(height: AppSpacing.sm),
                  ...pendientes.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _PendingRequestCard(
                        asignacion: a,
                        onCancelar: () =>
                            _confirmarCancelarSolicitud(context, ref, a),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Responsables
                _SectionHeader('RESPONSABLES'),
                const SizedBox(height: AppSpacing.sm),
                if (responsables.isEmpty)
                  _EmptySubsection('No hay responsables asignados.')
                else
                  ...responsables.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: MemberCard(
                        asignacion: a,
                        isCurrentUser: a.colaborador.id == usuarioId,
                        showChevron: puedeAdministrar,
                        onTap: puedeAdministrar
                            ? () => context.pushNamed(
                                AppRoutes.careTeamMemberName,
                                pathParameters: {'memberId': a.id.toString()},
                              )
                            : null,
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Cuidadores
                _SectionHeader('CUIDADORES'),
                const SizedBox(height: AppSpacing.sm),
                if (cuidadores.isEmpty)
                  _EmptySubsection('No hay cuidadores asignados.')
                else
                  ...cuidadores.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: MemberCard(
                        asignacion: a,
                        isCurrentUser: a.colaborador.id == usuarioId,
                        showChevron: puedeAdministrar,
                        onTap: puedeAdministrar
                            ? () => context.pushNamed(
                                AppRoutes.careTeamMemberName,
                                pathParameters: {'memberId': a.id.toString()},
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TODO(integración): eliminarMiembroProvider sigue en demo.
  // Conectar al endpoint real de cancelación cuando esté disponible.
  Future<void> _confirmarCancelarSolicitud(
    BuildContext context,
    WidgetRef ref,
    AsignacionCuidado asignacion,
  ) async {
    final nombre = asignacion.colaborador.nombreCompleto;

    final confirmo = await ConfirmDialog.show(
      context,
      title: '¿Cancelar la solicitud?',
      body:
          'Se cancelará la invitación enviada a $nombre. '
          'Podés volver a invitarlo más adelante.',
      confirmLabel: 'Cancelar solicitud',
      icon: Icons.cancel_outlined,
      accentColor: AppColors.error,
      onConfirm: () async {
        final eliminar = ref.read(eliminarMiembroProvider);
        await eliminar(
          asignacionId: asignacion.id,
          personaCuidadaId: personaCtx.id,
        );
      },
    );

    if (confirmo && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud a $nombre cancelada.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _EmptySubsection extends StatelessWidget {
  const _EmptySubsection(this.mensaje);
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        mensaje,
        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

class _EmptyNoPersonas extends StatelessWidget {
  const _EmptyNoPersonas();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No tenés personas a cargo registradas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Primero registrá una persona a cargo para poder gestionar su equipo de cuidado.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonTeam extends StatelessWidget {
  const _SkeletonTeam();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 36,
            width: 220,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < 3; i++) ...[
            Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.asignacion,
    required this.onCancelar,
  });

  final AsignacionCuidado asignacion;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) {
    final colaborador = asignacion.colaborador;
    final esResponsable = asignacion.rol.id == RolesCuidadoConst.responsable;
    final rolLabel = esResponsable ? 'Responsable' : 'Cuidador';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: const Color(0xFFF5A623), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarInitial(nombre: colaborador.nombre, size: 44),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      colaborador.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (colaborador.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        colaborador.email!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const _PendingChip(),
                        const SizedBox(width: 6),
                        Text(
                          'Invitado como $rolLabel',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Cancelar solicitud'),
              onPressed: onCancelar,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingChip extends StatelessWidget {
  const _PendingChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: const Color(0xFFF5A623), width: 1),
      ),
      child: const Text(
        'Pendiente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7A5200),
        ),
      ),
    );
  }
}
