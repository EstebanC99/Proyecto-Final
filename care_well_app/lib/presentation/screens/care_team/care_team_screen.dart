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
    final esResponsableAsync = ref.watch(esResponsableProvider);
    final usuario = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Equipo de cuidado'),
        actions: [
          esResponsableAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (esResp) => esResp
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
            usuarioId: usuario?.persona.id ?? '',
          );
        },
      ),
      floatingActionButton: esResponsableAsync.maybeWhen(
        data: (esResp) => esResp
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
  final String usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asignacionesAsync = ref.watch(
      careTeamAssignmentsProvider(personaCtx.id),
    );

    return asignacionesAsync.when(
      loading: () => const _SkeletonTeam(),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: InlineErrorBanner(message: 'No se pudo cargar el equipo.'),
      ),
      data: (asignaciones) {
        final responsables = asignaciones
            .where((a) => a.rol.nombre == RolCuidado.responsable)
            .toList();
        final cuidadores = asignaciones
            .where((a) => a.rol.nombre == RolCuidado.cuidador)
            .toList();

        return SingleChildScrollView(
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
                      isCurrentUser: a.personaColaborador.id == usuarioId,
                      onTap: () => context.pushNamed(
                        AppRoutes.careTeamMemberName,
                        pathParameters: {'memberId': a.id},
                      ),
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
                      isCurrentUser: a.personaColaborador.id == usuarioId,
                      onTap: () => context.pushNamed(
                        AppRoutes.careTeamMemberName,
                        pathParameters: {'memberId': a.id},
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
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
