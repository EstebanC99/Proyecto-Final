import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routers/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
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
    final responsableAsync = ref.watch(dependentsAsResponsableProvider);
    final cuidadorAsync = ref.watch(dependentsAsCuidadorProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Personas a cargo'),
      ),
      body: _Body(
        responsableAsync: responsableAsync,
        cuidadorAsync: cuidadorAsync,
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

class _Body extends StatelessWidget {
  const _Body({required this.responsableAsync, required this.cuidadorAsync});

  final AsyncValue<List<dynamic>> responsableAsync;
  final AsyncValue<List<dynamic>> cuidadorAsync;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            data: (personas) {
              if (personas.isEmpty) {
                return _EmptySection(
                  icon: Icons.person_outline,
                  mensaje: 'Aún no agregaste personas a cargo.',
                  ctaLabel: 'Agregar persona',
                  onCta: () => context.pushNamed(AppRoutes.dependentsNewName),
                );
              }
              return Column(
                children: personas
                    .map(
                      (p) => PersonCard(
                        persona: p,
                        rolLabel: 'Responsable',
                        onTap: () => context.pushNamed(
                          AppRoutes.dependentDetailName,
                          pathParameters: {'id': p.id},
                        ),
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
              child: InlineErrorBanner(message: 'No se pudo cargar la lista.'),
            ),
            data: (personas) {
              if (personas.isEmpty) {
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
                children: personas
                    .map(
                      (p) => PersonCard(
                        persona: p,
                        rolLabel: 'Cuidador',
                        onTap: () => context.pushNamed(
                          AppRoutes.dependentDetailName,
                          pathParameters: {'id': p.id},
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 96), // espacio para FAB
        ],
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
