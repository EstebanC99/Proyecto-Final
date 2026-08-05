import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import 'avatar.dart' show imageProviderFromBase64;

/// Campo de captura de la foto del documento de identidad.
///
/// Presenta dos estados:
/// - Vacío: una tarjeta con marco punteado, ícono y texto guía que invita a
///   capturar la foto.
/// - Con foto: una vista previa de la imagen (relación de aspecto de tarjeta)
///   con acciones para cambiarla o quitarla.
///
/// Es puramente presentacional: la lógica de captura vive en [onCapture]
/// (típicamente `pickDocumentImageAsBase64`).
class DocumentCaptureField extends StatelessWidget {
  const DocumentCaptureField({
    super.key,
    required this.imagenBase64,
    required this.onCapture,
    required this.onRemove,
    this.errorText,
  });

  /// Imagen del documento en base64 estándar (sin prefijo). `null` si no se
  /// capturó todavía.
  final String? imagenBase64;

  /// Acción para capturar (o recapturar) la foto.
  final VoidCallback onCapture;

  /// Acción para quitar la foto capturada.
  final VoidCallback onRemove;

  /// Mensaje de error a mostrar debajo del campo (ej. falta la foto).
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tieneError = errorText != null;
    final imagen = imageProviderFromBase64(imagenBase64);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (imagen != null)
          _PreviewFoto(imagen: imagen)
        else
          _CapturaVacia(hasError: tieneError, onTap: onCapture),
        if (imagen != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCapture,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  label: const Text('Cambiar'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Quitar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (tieneError) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.sm),
            child: Text(
              errorText!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: context.colors.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Estado vacío: tarjeta con marco e invitación a capturar.
class _CapturaVacia extends StatelessWidget {
  const _CapturaVacia({required this.hasError, required this.onTap});

  final bool hasError;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = hasError
        ? context.colors.error
        : context.colors.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AspectRatio(
        aspectRatio: 1.585,
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.primaryContainer.withValues(alpha: 0.25),
            border: Border.all(color: borderColor, width: hasError ? 1.5 : 1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.badge_outlined,
                size: 40,
                color: context.colors.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tocá para tomar la foto de tu DNI',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Deben leerse con claridad tu nombre, apellido y número.',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vista previa de la foto capturada.
class _PreviewFoto extends StatelessWidget {
  const _PreviewFoto({required this.imagen});

  final ImageProvider imagen;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.585,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: context.colors.outline),
          image: DecorationImage(image: imagen, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
