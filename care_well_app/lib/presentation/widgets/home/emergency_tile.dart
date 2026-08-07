import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../shared/full_width_action_tile.dart';

/// Tile de emergencia full-width. Siempre visible y activo.
///
/// Relleno sólido con [AppPalette.emergencyRed] para que se lea como acción de
/// riesgo, en línea con el botón grande de la pantalla de Emergencia. La tinta
/// es [AppPalette.onEmergency] y no `onPrimary`: en tema oscuro el rojo se
/// aclara y el blanco no alcanzaría el contraste mínimo.
/// Delega el layout y la animación en [FullWidthActionTile].
class EmergencyTile extends StatelessWidget {
  const EmergencyTile({
    super.key,
    required this.onTap,
    this.delay = Duration.zero,
  });

  final VoidCallback onTap;

  /// Delay para la animación de entrada FadeInUp.
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return FullWidthActionTile(
      icon: Icons.warning_amber_rounded,
      label: 'Emergencia',
      color: context.colors.emergencyRed,
      foregroundColor: context.colors.onEmergency,
      pressedColor: context.colors.emergencyRedPressed,
      onTap: onTap,
      delay: delay,
    );
  }
}
