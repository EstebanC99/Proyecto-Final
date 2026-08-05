import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../shared/inline_error_banner.dart';

/// Dialog de confirmación anti-accidental para activar la emergencia.
///
/// Uso:
/// ```dart
/// final confirmo = await EmergencyConfirmDialog.show(
///   context,
///   nombrePersona: 'Alicia',
///   onConfirm: () async { ... },
/// );
/// ```
class EmergencyConfirmDialog extends StatefulWidget {
  const EmergencyConfirmDialog({
    super.key,
    required this.nombrePersona,
    required this.onConfirm,
  });

  final String nombrePersona;
  final Future<void> Function() onConfirm;

  /// Muestra el dialog y retorna `true` si el usuario confirmó.
  static Future<bool?> show(
    BuildContext context, {
    required String nombrePersona,
    required Future<void> Function() onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => EmergencyConfirmDialog(
        nombrePersona: nombrePersona,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<EmergencyConfirmDialog> createState() => _EmergencyConfirmDialogState();
}

class _EmergencyConfirmDialogState extends State<EmergencyConfirmDialog> {
  bool _loading = false;
  String? _errorMessage;

  Future<void> _handleConfirm() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = 'No se pudo enviar la alerta. Verificá tu conexión.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_loading,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Franja roja superior
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: context.colors.emergencyRed,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusXl),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícono
                  ExcludeSemantics(
                    child: Icon(
                      Icons.notifications_active,
                      size: 48,
                      color: context.colors.emergencyRed,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Título
                  Text(
                    '¿Activar emergencia?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Cuerpo
                  Text(
                    'Se enviará una alerta urgente al equipo de cuidado de '
                    '${widget.nombrePersona}. '
                    'Usá esto solo ante una situación real.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  // Error banner
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    InlineErrorBanner(message: _errorMessage!),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  // Botón confirmar
                  Semantics(
                    label:
                        'Confirmar. Enviar alerta de emergencia al equipo de cuidado.',
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _loading ? null : _handleConfirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colors.emergencyRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                        ),
                        child: _loading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: context.colors.onEmergency,
                                ),
                              )
                            : Text(
                                'Sí, enviar alerta',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.onEmergency,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Botón cancelar
                  Semantics(
                    label: 'Cancelar. Cerrar sin enviar alerta.',
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.primary,
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
