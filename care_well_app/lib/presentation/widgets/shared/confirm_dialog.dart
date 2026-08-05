import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';

/// Diálogo de confirmación de acción destructiva reutilizable.
///
/// Muestra un ícono de alerta, título, cuerpo y dos botones:
/// - Botón destructivo: llama [onConfirm] mostrando spinner mientras ejecuta.
/// - Botón "Cancelar": cierra el diálogo sin ejecutar la acción.
///
/// Retorna `true` si el usuario confirmó, `false` si canceló.
///
/// Uso:
/// ```dart
/// final confirmo = await ConfirmDialog.show(
///   context,
///   title: '¿Eliminar?',
///   body: 'Esta acción no se puede deshacer.',
///   confirmLabel: 'Eliminar',
///   onConfirm: () async { await repo.eliminar(id); },
/// );
/// ```
class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.onConfirm,
    this.icon,
    this.accentColor,
  });

  /// Título del diálogo.
  final String title;

  /// Cuerpo explicativo.
  final String body;

  /// Etiqueta del botón destructivo.
  final String confirmLabel;

  /// Acción asíncrona que se ejecuta al confirmar.
  final Future<void> Function() onConfirm;

  /// Ícono opcional. Por defecto [Icons.person_remove_outlined].
  final IconData? icon;

  /// Color de acento del ícono y del botón de confirmación.
  ///
  /// Si es `null` se resuelve contra el tema vigente como [AppPalette.error]
  /// (variante destructiva). Para acciones no destructivas (p. ej. reactivar)
  /// pasar un color positivo como [AppPalette.primary] o [AppPalette.success].
  final Color? accentColor;

  /// Muestra el diálogo y retorna `true` si el usuario confirmó la acción.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
    IconData? icon,
    Color? accentColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        icon: icon,
        accentColor: accentColor,
      ),
    );
    return result ?? false;
  }

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  bool _loading = false;

  Future<void> _handleConfirm() async {
    setState(() => _loading = true);
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // El acento por defecto se resuelve acá (y no en el constructor) para que
    // siga al tema vigente: un valor por defecto tiene que ser constante.
    final accentColor = widget.accentColor ?? context.colors.error;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      contentPadding: const EdgeInsets.all(AppSpacing.xl),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon ?? Icons.person_remove_outlined,
            size: 48,
            color: accentColor,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Botón destructivo
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: _loading ? null : _handleConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: _loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.colors.onPrimary,
                      ),
                    )
                  : Text(
                      widget.confirmLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colors.onPrimary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          // Botón cancelar
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.colors.outline, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
