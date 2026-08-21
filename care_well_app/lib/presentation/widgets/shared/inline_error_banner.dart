import 'package:flutter/material.dart';

import '../../../config/theme/theme.dart';

/// Tono semántico de [InlineErrorBanner].
///
/// - [error]: algo salió mal / el usuario debe corregir algo. Rojo.
/// - [warning]: requiere atención pero no es una falla del usuario. Ámbar.
///   Usar para estados de negocio esperables que bloquean el paso siguiente
///   (ej. cuenta aún no habilitada) sin que se perciban como un error propio.
/// - [info]: aclaración neutra, no bloqueante. Azul.
enum BannerTone { error, warning, info }

/// Banner inline reutilizable para mensajes de estado dentro de un formulario.
///
/// Además del mensaje admite una acción secundaria opcional (ej. "Verificar
/// mi email") para convertir un estado bloqueante en un próximo paso concreto.
class InlineErrorBanner extends StatelessWidget {
  const InlineErrorBanner({
    super.key,
    required this.message,
    this.tone = BannerTone.error,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  final String message;

  /// Tono visual. Por defecto [BannerTone.error] (compatibilidad retroactiva).
  final BannerTone tone;

  /// Ícono a mostrar. Si es `null` se usa el ícono por defecto del [tone].
  final IconData? icon;

  /// Etiqueta de una acción secundaria opcional (ej. "Verificar mi email").
  final String? actionLabel;

  /// Callback de la acción secundaria. Requerido junto con [actionLabel].
  final VoidCallback? onAction;

  /// Callback del descarte. Si es `null` el banner no se puede cerrar.
  ///
  /// Reservado para avisos no bloqueantes que el usuario puede convivir con
  /// ellos: un error que exige corrección no debería poder ocultarse.
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (
      Color background,
      Color foreground,
      IconData defaultIcon,
    ) = switch (tone) {
      BannerTone.error => (
        theme.colorScheme.errorContainer,
        theme.colorScheme.error,
        Icons.error_outline,
      ),
      BannerTone.warning => (
        context.colors.warningContainer,
        context.colors.warning,
        Icons.info_outline,
      ),
      BannerTone.info => (
        context.colors.infoContainer,
        context.colors.info,
        Icons.info_outline,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon ?? defaultIcon, color: foreground, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    height: 1.4,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                  iconSize: 18,
                  color: foreground,
                  tooltip: 'Descartar aviso',
                  padding: EdgeInsets.zero,
                  // El ícono es chico por jerarquía visual, pero el área
                  // tocable respeta el mínimo accesible.
                  constraints: const BoxConstraints(
                    minWidth: AppSpacing.minTapTarget,
                    minHeight: AppSpacing.minTapTarget,
                  ),
                  // Alinea la cruz con el ícono del tono, en vez de centrarla
                  // en los 48dp del área tocable.
                  alignment: Alignment.topCenter,
                ),
            ],
          ),
          if (actionLabel != null && onAction != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: foreground,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  textStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ),
        ],
      ),
    );
  }
}
