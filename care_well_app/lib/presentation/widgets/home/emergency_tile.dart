import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../shared/full_width_action_tile.dart';

/// Tile de emergencia full-width. Siempre visible y activo.
///
/// Fondo [AppPalette.secondary] (coral), ícono de advertencia y texto blancos.
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
      color: context.colors.secondary,
      onTap: onTap,
      delay: delay,
    );
  }
}
