import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

/// US-06 · Visualización del perfil del usuario autenticado.
///
/// Pantalla de solo lectura. Los datos no son editables aquí; la edición
/// pertenece a US-07 ([ProfileEditScreen]).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final rol = ref.watch(rolEnSistemaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar perfil',
            onPressed: () => context.pushNamed(AppRoutes.profileEditName),
          ),
        ],
      ),
      body: authState.when(
        loading: () => const _ProfileSkeleton(),
        error: (error, _) => _ProfileError(
          message: error.toString(),
          onRetry: () => ref.invalidate(authStateProvider),
        ),
        data: (usuario) {
          if (usuario == null) return const SizedBox.shrink();

          final persona = usuario.persona;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Encabezado de perfil
                Container(
                  width: double.infinity,
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      ProfileAvatar(nombre: persona.nombre),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        persona.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      RoleBadge(rol: rol),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.outline,
                ),

                // Sección de datos
                ProfileDataRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: persona.email ?? '',
                ),
                ProfileDataRow(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: persona.telefono ?? '',
                ),
                ProfileDataRow(
                  icon: Icons.badge_outlined,
                  label: 'DNI',
                  value: persona.documento,
                ),
                ProfileDataRow(
                  icon: Icons.person_outlined,
                  label: 'Rol en el sistema',
                  value: rol,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Skeleton de carga para el perfil.
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 160,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 90,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.outline),
          for (int i = 0; i < 4; i++) ...[
            Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              color: AppColors.surface,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.outline,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 140,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.outline,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.outline),
          ],
        ],
      ),
    );
  }
}

/// Banner de error inline para el perfil.
class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InlineErrorBanner(
            message: 'No se pudieron cargar los datos. $message',
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
