import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../shared/avatar.dart';
import '../shared/persona_avatar.dart';

/// Barra de identidad y saludo del menú principal.
///
/// Lado izquierdo: ícono de marca + wordmark bicolor "CareWell".
/// Lado derecho tappable — navega a Configuración vía [onTapProfile].
class HomeHeader extends ConsumerWidget {
  const HomeHeader({
    super.key,
    required this.userName,
    this.personaId,
    this.onTapProfile,
  });

  /// Nombre del usuario para el saludo y la inicial del avatar.
  final String userName;

  /// Id de la persona autenticada para resolver su foto de perfil. Si es
  /// `null` (aún sin sesión), el avatar cae al fallback de inicial.
  final int? personaId;

  /// Callback invocado al tocar el área derecha (avatar + saludo).
  final VoidCallback? onTapProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: Container(
        height: 64,
        color: context.colors.surface,
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
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Care',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: 'Well',
                    style: TextStyle(
                      color: context.colors.primary,
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
                        // Avatar circular: foto de perfil (por personaId) con
                        // fallback a inicial.
                        personaId != null
                            ? PersonaAvatar(
                                personaId: personaId!,
                                nombre: userName,
                                size: 40,
                              )
                            : Avatar(nombre: userName, size: 40),
                        const SizedBox(width: AppSpacing.sm),
                        // Saludo
                        Text(
                          'Hola, $userName',
                          style: TextStyle(
                            color: context.colors.textPrimary,
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
