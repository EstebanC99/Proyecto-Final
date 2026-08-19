import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../domain/entities/entities.dart';
import '../shared/persona_avatar.dart';

/// Tarjeta de identidad del usuario en Configuración.
///
/// Muestra quién tiene la sesión abierta (avatar, nombre y email) y funciona
/// como acceso a "Mi Perfil": toda la superficie es tocable, el pill
/// "Ver perfil" es decorativo.
///
/// Es presentación pura: recibe la [Persona] ya resuelta en lugar de leer
/// providers propios (mismo criterio que `PersonaContextHeaderCard`). La única
/// dependencia de Riverpod es indirecta, vía [PersonaAvatar], que resuelve la
/// foto de perfil.
class SettingsUserCard extends StatelessWidget {
  const SettingsUserCard({
    super.key,
    required this.persona,
    required this.onTap,
  });

  /// Persona del usuario autenticado.
  final Persona persona;

  /// Callback al tocar la tarjeta (navega al perfil).
  final VoidCallback onTap;

  /// Diámetro del avatar, sin contar el anillo que lo rodea.
  static const double _avatarSize = 52;

  @override
  Widget build(BuildContext context) {
    final email = persona.email;
    final tieneEmail = email != null && email.isNotEmpty;

    return Semantics(
      button: true,
      // El email forma parte de la lectura: esta tarjeta es el único lugar de
      // la app donde se comunica con qué cuenta está abierta la sesión, y un
      // usuario de lector de pantalla tiene que poder verificarlo sin entrar
      // al perfil.
      label: tieneEmail
          ? '${persona.nombreCompleto}, $email. Ver perfil'
          : '${persona.nombreCompleto}. Ver perfil',
      child: ExcludeSemantics(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppSpacing.elev1,
          ),
          // El Material transparente habilita el ripple del InkWell: sin él, el
          // fondo del Container lo taparía (mismo patrón que `CardGroup`).
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    _AvatarConAnillo(persona: persona),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            persona.nombreCompleto,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          if (tieneEmail) ...[
                            const SizedBox(height: 2),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: context.colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const _VerPerfilPill(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar de la persona rodeado por un anillo del color de marca, separado del
/// círculo por un hilo del color de la tarjeta.
class _AvatarConAnillo extends StatelessWidget {
  const _AvatarConAnillo({required this.persona});

  final Persona persona;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: context.colors.primary, width: 2),
      ),
      child: PersonaAvatar(
        personaId: persona.id,
        nombre: persona.nombre,
        size: SettingsUserCard._avatarSize,
      ),
    );
  }
}

/// Pill decorativo "Ver perfil".
///
/// No es un botón: la acción la tiene la tarjeta entera. Se excluye de la
/// semántica para no anunciar un segundo control.
class _VerPerfilPill extends StatelessWidget {
  const _VerPerfilPill();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.colors.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          'Ver perfil',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: context.colors.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

/// Placeholder de [SettingsUserCard] mientras se resuelve la sesión.
///
/// Estático a propósito (bloques planos, sin shimmer ni spinner): una animación
/// infinita colgaría los `pumpAndSettle()` de los tests y no aporta información.
/// Mantiene la misma caja y alto que la tarjeta real para que la transición
/// loading → data no mueva el layout.
class SettingsUserCardSkeleton extends StatelessWidget {
  const SettingsUserCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // 52 del avatar + 2 de separación + 2 del anillo, a cada lado.
    const diametroConAnillo = SettingsUserCard._avatarSize + 8;

    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: AppSpacing.elev1,
        ),
        child: Row(
          children: [
            Container(
              width: diametroConAnillo,
              height: diametroConAnillo,
              decoration: BoxDecoration(
                color: context.colors.outline,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _BloqueGris(width: 140, height: 16),
                  SizedBox(height: 6),
                  _BloqueGris(width: 180, height: 12),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const _BloqueGris(width: 72, height: 30),
          ],
        ),
      ),
    );
  }
}

/// Bloque plano del skeleton.
class _BloqueGris extends StatelessWidget {
  const _BloqueGris({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.colors.outline,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
    );
  }
}
