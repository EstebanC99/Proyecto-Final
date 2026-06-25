import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constraints/validators.dart';
import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-14/15 · Detalle y baja de persona a cargo.
///
/// Muestra los datos de la persona con edición inline campo a campo.
/// El AppBar incluye la acción "Eliminar persona" en el menú contextual.
class DependentDetailScreen extends ConsumerWidget {
  const DependentDetailScreen({super.key, required this.dependentId});

  final int dependentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personaAsync = ref.watch(dependentByIdProvider(dependentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Persona a cargo'),
        actions: [
          // US-15: Menú con opción eliminar
          personaAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (persona) => PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'eliminar') {
                  await _confirmarEliminar(
                    context,
                    ref,
                    persona.nombreCompleto,
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppColors.error),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'Eliminar persona',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: personaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: InlineErrorBanner(
            message:
                'No se pudo cargar la persona. ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
        data: (persona) => SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    AvatarInitial(nombre: persona.nombre, size: 80),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      persona.nombreCompleto,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (persona.fechaNacimiento != null) ...[
                      Text(
                        () {
                          final edad = calcularEdad(persona.fechaNacimiento);
                          return edad != null ? '$edad años' : '';
                        }(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    const RoleBadge(rol: 'Persona a cargo'),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.outline),

              // Campos de datos
              ProfileDataRow(
                icon: Icons.person_outline,
                label: 'Nombre',
                value: persona.nombre,
                editable: true,
                validator: validateNombre,
                onSave: (v) async {
                  final actualizar = ref.read(actualizarDependenteProvider);
                  await actualizar(persona.copyWith(nombre: v));
                  ref.invalidate(dependentByIdProvider(dependentId));
                },
              ),
              ProfileDataRow(
                icon: Icons.person_outline,
                label: 'Apellido',
                value: persona.apellido,
                editable: true,
                validator: validateApellido,
                onSave: (v) async {
                  final actualizar = ref.read(actualizarDependenteProvider);
                  await actualizar(persona.copyWith(apellido: v));
                  ref.invalidate(dependentByIdProvider(dependentId));
                },
              ),
              // DNI: NO editable
              ProfileDataRow(
                icon: Icons.badge_outlined,
                label: 'DNI',
                value: persona.documento ?? '',
              ),
              // Fecha nacimiento: NO editable
              ProfileDataRow(
                icon: Icons.calendar_month_outlined,
                label: 'Fecha de nacimiento',
                value: persona.fechaNacimiento != null
                    ? '${persona.fechaNacimiento!.day.toString().padLeft(2, '0')}/${persona.fechaNacimiento!.month.toString().padLeft(2, '0')}/${persona.fechaNacimiento!.year}'
                    : '',
              ),
              // Email: editable
              ProfileDataRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: persona.email ?? '',
                editable: true,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  return validateEmail(v);
                },
                onSave: (v) async {
                  final actualizar = ref.read(actualizarDependenteProvider);
                  await actualizar(
                    persona.copyWith(email: v.isEmpty ? null : v),
                  );
                  ref.invalidate(dependentByIdProvider(dependentId));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    String nombreCompleto,
  ) async {
    final confirmo = await ConfirmDialog.show(
      context,
      title: '¿Eliminar a $nombreCompleto?',
      body:
          '$nombreCompleto será eliminado de tu lista de personas a cargo. '
          'Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      icon: Icons.delete_outline,
      onConfirm: () async {
        final eliminar = ref.read(eliminarDependenteProvider);
        await eliminar(dependentId);
      },
    );
    if (confirmo && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$nombreCompleto fue eliminado.'),
          backgroundColor: AppColors.success,
        ),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.goNamed(AppRoutes.dependentsName);
      }
    }
  }
}
