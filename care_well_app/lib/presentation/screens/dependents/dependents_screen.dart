import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-13 · Listado de personas a cargo.
///
/// Muestra dos secciones: "COMO RESPONSABLE" y "COMO CUIDADOR".
/// FAB visible en la sección de responsable (incluso en estado vacío).
class DependentsScreen extends ConsumerWidget {
  const DependentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsableAsync = ref.watch(asignacionesComoResponsableProvider);
    final cuidadorAsync = ref.watch(asignacionesComoCuidadorProvider);
    final pendientesAsync = ref.watch(
      asignacionesPendientesComoCuidadorProvider,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Personas a cargo'),
      ),
      body: _Body(
        responsableAsync: responsableAsync,
        cuidadorAsync: cuidadorAsync,
        pendientesAsync: pendientesAsync,
      ),
      floatingActionButton: responsableAsync.when(
        loading: () => null,
        error: (e, st) => null,
        data: (lista) => FloatingActionButton(
          onPressed: () => context.pushNamed(AppRoutes.dependentsNewName),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          tooltip: 'Agregar persona',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({
    required this.responsableAsync,
    required this.cuidadorAsync,
    required this.pendientesAsync,
  });

  final AsyncValue<List<AsignacionCuidado>> responsableAsync;
  final AsyncValue<List<AsignacionCuidado>> cuidadorAsync;
  final AsyncValue<List<AsignacionCuidado>> pendientesAsync;

  /// Construye el callback de tap para una asignación según su estado y rol.
  ///
  /// - Inactiva + Responsable → confirma la reactivación.
  /// - Inactiva + Cuidador → no interactiva (`null`).
  /// - Activa o pendiente → navega al detalle.
  VoidCallback? _onTapAsignacion(
    BuildContext context,
    WidgetRef ref,
    AsignacionCuidado a,
  ) {
    final esInactiva = a.estado.id == EstadosAsignacionConst.inactiva;
    if (esInactiva) {
      if (a.rol.id == RolesCuidadoConst.responsable) {
        return () => _confirmarReactivar(context, ref, a);
      }
      return null;
    }
    return () => context.pushNamed(
      AppRoutes.dependentDetailName,
      pathParameters: {'id': a.id.toString()},
    );
  }

  Future<void> _confirmarAceptar(
    BuildContext context,
    WidgetRef ref,
    AsignacionCuidado asignacion,
  ) async {
    final nombre = asignacion.personaCuidada.nombreCompleto;

    final confirmo = await ConfirmDialog.show(
      context,
      title: '¿Aceptar esta invitación?',
      body: 'Formarás parte del equipo de cuidado de $nombre.',
      confirmLabel: 'Aceptar',
      icon: Icons.check_circle_outline,
      accentColor: AppColors.success,
      onConfirm: () async {
        final activar = ref.read(activarAsignacionProvider);
        await activar(asignacion: asignacion);
      },
    );

    if (confirmo && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Te uniste al equipo de cuidado de $nombre.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _confirmarRechazar(
    BuildContext context,
    WidgetRef ref,
    AsignacionCuidado asignacion,
  ) async {
    final nombre = asignacion.personaCuidada.nombreCompleto;

    final confirmo = await ConfirmDialog.show(
      context,
      title: '¿Rechazar esta invitación?',
      body:
          'No formarás parte del equipo de cuidado de $nombre. '
          'La invitación será eliminada.',
      confirmLabel: 'Rechazar',
      icon: Icons.cancel_outlined,
      accentColor: AppColors.error,
      onConfirm: () async {
        final eliminar = ref.read(eliminarAsignacionProvider);
        await eliminar(asignacion: asignacion);
      },
    );

    if (confirmo && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rechazaste la invitación de $nombre.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Muestra el diálogo de confirmación y reactiva la asignación.
  Future<void> _confirmarReactivar(
    BuildContext context,
    WidgetRef ref,
    AsignacionCuidado asignacion,
  ) async {
    final nombre = asignacion.personaCuidada.nombreCompleto;

    final confirmo = await ConfirmDialog.show(
      context,
      title: '¿Reactivar esta asignación?',
      body:
          '$nombre volverá a tu lista de personas a cargo y se '
          'cancelará su baja definitiva.',
      confirmLabel: 'Reactivar',
      icon: Icons.restore,
      accentColor: AppColors.primary,
      onConfirm: () async {
        final reactivar = ref.read(reactivarAsignacionProvider);
        await reactivar(asignacion: asignacion);
      },
    );

    if (confirmo && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$nombre fue reactivado.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(misAsignacionesProvider);
        await ref.read(misAsignacionesProvider.future);
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección Invitaciones pendientes (solo si hay alguna).
            ...pendientesAsync.maybeWhen(
              orElse: () => const <Widget>[],
              data: (invitaciones) {
                if (invitaciones.isEmpty) return const <Widget>[];
                return [
                  _SectionLabel('INVITACIONES DE CUIDADO'),
                  ...invitaciones.map(
                    (a) => _PendingCard(
                      asignacion: a,
                      onAceptar: () => _confirmarAceptar(context, ref, a),
                      onRechazar: () => _confirmarRechazar(context, ref, a),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ];
              },
            ),

            // Sección Responsable
            _SectionLabel('COMO RESPONSABLE'),
            responsableAsync.when(
              loading: () => const _SkeletonList(),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: InlineErrorBanner(
                  message:
                      'No se pudo cargar la lista. ${e.toString().replaceFirst('Exception: ', '')}',
                ),
              ),
              data: (asignaciones) {
                if (asignaciones.isEmpty) {
                  return _EmptySection(
                    icon: Icons.person_outline,
                    mensaje: 'Aún no agregaste personas a cargo.',
                    ctaLabel: 'Agregar persona',
                    onCta: () => context.pushNamed(AppRoutes.dependentsNewName),
                  );
                }
                return Column(
                  children: asignaciones
                      .map(
                        (a) => PersonCard(
                          asignacion: a,
                          onTap: _onTapAsignacion(context, ref, a),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Sección Cuidador
            _SectionLabel('COMO CUIDADOR'),
            cuidadorAsync.when(
              loading: () => const _SkeletonList(),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: InlineErrorBanner(
                  message: 'No se pudo cargar la lista.',
                ),
              ),
              data: (asignaciones) {
                // Las invitaciones pendientes se muestran en su propia sección,
                // por lo que se excluyen de "Como cuidador".
                final visibles = asignaciones
                    .where(
                      (a) => a.estado.id != EstadosAsignacionConst.pendiente,
                    )
                    .toList();
                if (visibles.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      'No participás como cuidador en ningún equipo.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }
                return Column(
                  children: visibles
                      .map(
                        (a) => PersonCard(
                          asignacion: a,
                          onTap: _onTapAsignacion(context, ref, a),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 96), // espacio para FAB
          ],
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.icon,
    required this.mensaje,
    required this.ctaLabel,
    required this.onCta,
  });

  final IconData icon;
  final String mensaje;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            mensaje,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(label: ctaLabel, onPressed: onCta),
        ],
      ),
    );
  }
}

/// Tarjeta de invitación de cuidado pendiente.
///
/// Muestra el nombre de la persona cuidada, chip "Pendiente" y botones inline
/// para Aceptar o Rechazar sin necesidad de navegar al detalle.
class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.asignacion,
    required this.onAceptar,
    required this.onRechazar,
  });

  final AsignacionCuidado asignacion;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;

  @override
  Widget build(BuildContext context) {
    final persona = asignacion.personaCuidada;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 5,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: const Color(0xFFF5A623), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AvatarInitial(nombre: persona.nombre, size: 52),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        persona.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Te invitaron a cuidar a ${persona.nombre}.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const _PendingChip(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Aceptar'),
                    onPressed: onAceptar,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Rechazar'),
                    onPressed: onRechazar,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip de estado "Pendiente".
///
/// Replica el chip homónimo de [PersonCard] (privado a su archivo) para usarlo
/// en [_PendingCard] sin acoplar ambos widgets.
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

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 5,
          ),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}
