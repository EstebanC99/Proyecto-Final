import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';

/// Barra de identidad y saludo del menú principal.
///
/// Lado izquierdo: ícono de marca + wordmark bicolor "CareWell".
/// Lado derecho tappable — navega a Configuración vía [onTapProfile].
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.userName, this.onTapProfile});

  /// Nombre del usuario para el saludo y la inicial del avatar.
  final String userName;

  /// Callback invocado al tocar el área derecha (avatar + saludo).
  final VoidCallback? onTapProfile;

  @override
  Widget build(BuildContext context) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Container(
        height: 64,
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          children: [
            // Logo izquierdo
            Image.asset(
              'assets/images/carewell-logo.png',
              width: 36,
              height: 36,
            ),
            const SizedBox(width: AppSpacing.sm),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Care',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: 'Well',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Área derecha tappable: avatar + saludo. Navega a Configuración.
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: InkWell(
                onTap: () => onTapProfile?.call(),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.minTapTarget,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar circular con inicial
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: AppColors.onPrimaryContainer,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Saludo
                        Text(
                          'Hola, $userName',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
