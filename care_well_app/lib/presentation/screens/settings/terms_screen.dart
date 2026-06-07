import 'package:flutter/material.dart';

import '../../../config/constraints/terms_content.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// US-08 · Pantalla de lectura de Términos y Condiciones.
///
/// El contenido proviene de [kTermsContent], la misma fuente que usa
/// [TermsBottomSheet] en el flujo de registro. Solo lectura, sin acciones.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Términos y condiciones'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outline),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxxl + AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Versión $kTermsVersion',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  kTermsContent,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Deslizá para leer más',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Gradiente de fade al pie para indicar que el contenido continúa.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 32,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.surface.withAlpha(0), AppColors.surface],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
