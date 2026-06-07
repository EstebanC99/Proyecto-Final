import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Fila de accesos rápidos bajo el header: "Mi Perfil" y "Configuración".
///
/// Cada botón ocupa la mitad del ancho disponible.
/// Fondo [AppColors.surfaceVariant], radio 12, altura >= 48 dp.
class QuickAccessRow extends StatelessWidget {
  const QuickAccessRow({
    super.key,
    required this.onTapProfile,
    required this.onTapSettings,
    this.delay = Duration.zero,
  });

  final VoidCallback onTapProfile;
  final VoidCallback onTapSettings;

  /// Delay para la animación de entrada.
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      delay: delay,
      child: Row(
        children: [
          Expanded(
            child: _QuickButton(
              icon: Icons.person,
              label: 'Mi Perfil',
              onTap: onTapProfile,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _QuickButton(
              icon: Icons.settings,
              label: 'Configuración',
              onTap: onTapSettings,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatefulWidget {
  const _QuickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickButton> createState() => _QuickButtonState();
}

class _QuickButtonState extends State<_QuickButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: AppSpacing.minTapTarget,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.primaryContainer
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
