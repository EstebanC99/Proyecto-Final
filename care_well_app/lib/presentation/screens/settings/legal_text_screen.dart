import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Pantalla genérica de lectura de un texto legal.
///
/// La usan tanto los Términos y Condiciones (US-08) como la Política de
/// privacidad: el contenido llega por parámetro, así que la pantalla no conoce
/// ninguna de las dos fuentes ni depende de providers.
class LegalTextScreen extends StatelessWidget {
  const LegalTextScreen({
    super.key,
    required this.titulo,
    required this.contenido,
    this.version,
    this.hintScroll,
  });

  /// Título de la pantalla (ej: "Términos y condiciones").
  final String titulo;

  /// Cuerpo del documento legal.
  final String contenido;

  /// Versión del documento. Si es nula no se muestra el encabezado de versión.
  final String? version;

  /// Ayuda al pie que indica que el contenido continúa. Opcional.
  final String? hintScroll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Text(titulo),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: context.colors.outline),
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
                if (version != null) ...[
                  Text(
                    'Versión $version',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                Text(
                  contenido,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: context.colors.textPrimary,
                    height: 1.6,
                  ),
                ),
                if (hintScroll != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      hintScroll!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.colors.textDisabled,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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
                    colors: [
                      context.colors.surface.withAlpha(0),
                      context.colors.surface,
                    ],
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
