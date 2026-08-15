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
/// Lado derecho tappable — chip con el saludo y el avatar de la cuenta
/// logueada; navega a Configuración vía [onTapProfile].
///
/// El chip de cuenta es deliberadamente discreto (plano, sin anillo ni
/// sombra): identifica la sesión, mientras que la persona que se está
/// visualizando la comunica el selector de contexto, que va inmediatamente
/// debajo y sí tiene peso visual.
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
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        // Sin padding derecho: el chip de cuenta llega al borde de la
        // superficie del header. El padding izquierdo sí se mantiene, para
        // separar el logo del borde.
        padding: const EdgeInsets.only(left: AppSpacing.md),
        child: Row(
          children: [
            // Logo izquierdo
            Image.asset(
              'assets/images/carewell-logo.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: AppSpacing.sm),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Care',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextSpan(
                    text: 'Well',
                    style: TextStyle(
                      color: context.colors.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),

            // Área derecha tappable: chip de cuenta (saludo + avatar).
            // Va en un Expanded alineado a la derecha para que el saludo se
            // recorte con ellipsis en nombres largos en vez de desbordar.
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  child: InkWell(
                    onTap: () => onTapProfile?.call(),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    // El alto de 48 mantiene el área táctil mínima aunque el
                    // chip se vea más chico.
                    child: SizedBox(
                      height: AppSpacing.minTapTarget,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsetsGeometry.directional(end: 5),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(10, 3, 3, 3),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceVariant,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Saludo
                                Flexible(
                                  child: Text(
                                    'Hola, $userName',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.colors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                // Avatar circular: foto de perfil (por personaId)
                                // con fallback a inicial.
                                personaId != null
                                    ? PersonaAvatar(
                                        personaId: personaId!,
                                        nombre: userName,
                                        size: 30,
                                      )
                                    : Avatar(nombre: userName, size: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
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
