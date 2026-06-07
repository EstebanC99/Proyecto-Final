import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import 'primary_button.dart';

/// Vista de éxito reutilizable con animación en el ícono check.
///
/// Muestra un círculo verde con check, un título, un mensaje opcional con
/// nombre resaltado en negrita, y hasta dos botones de acción.
class SuccessView extends StatelessWidget {
  const SuccessView({
    super.key,
    required this.title,
    this.highlightedName,
    this.subtitle,
    required this.primaryButtonLabel,
    required this.onPrimaryTap,
    this.secondaryButtonLabel,
    this.onSecondaryTap,
  });

  /// Título principal. Ej: "¡Persona registrada!".
  final String title;

  /// Nombre resaltado en negrita dentro del subtítulo.
  final String? highlightedName;

  /// Subtítulo con contexto. El [highlightedName] se inserta antes de este texto.
  final String? subtitle;

  /// Etiqueta del botón primario.
  final String primaryButtonLabel;

  /// Acción del botón primario.
  final VoidCallback onPrimaryTap;

  /// Etiqueta del botón/link secundario. Opcional.
  final String? secondaryButtonLabel;

  /// Acción del botón/link secundario. Opcional.
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Ícono animado con TweenAnimationBuilder (rebote suave)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (_, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: const BoxDecoration(
                    color: AppColors.successContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Título
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              // Mensaje con nombre resaltado
              if (highlightedName != null || subtitle != null) ...[
                const SizedBox(height: AppSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      children: [
                        if (highlightedName != null)
                          TextSpan(
                            text: highlightedName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (subtitle != null) TextSpan(text: subtitle),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Botón primario
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: primaryButtonLabel,
                  onPressed: onPrimaryTap,
                ),
              ),
              // Botón/link secundario
              if (secondaryButtonLabel != null) ...[
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: onSecondaryTap,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    alignment: Alignment.center,
                    child: Text(
                      secondaryButtonLabel!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
