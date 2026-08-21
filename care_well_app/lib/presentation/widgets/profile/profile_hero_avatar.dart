import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import '../../../config/theme/app_spacing.dart';
import '../shared/avatar.dart';

/// Avatar del encabezado de "Mi perfil": foto grande con anillo y badge de
/// cámara.
///
/// Es específico del hero y no reemplaza a `EditableAvatar`: aquel vive sobre
/// fondo claro, tiene una sola acción y otro tamaño. Acá el círculo y el badge
/// son **dos acciones distintas**: el círculo abre el visor (si hay foto) y el
/// badge abre siempre el selector de origen.
///
/// Sin foto el círculo pasa a abrir el selector, para que el gesto natural
/// ("toco mi foto") haga algo útil en lugar de nada.
class ProfileHeroAvatar extends StatelessWidget {
  const ProfileHeroAvatar({
    super.key,
    required this.nombre,
    required this.imagen,
    required this.onVerFoto,
    required this.onCambiarFoto,
    this.size = 92,
  });

  /// Nombre del que se extrae la inicial cuando no hay foto.
  final String nombre;

  /// Foto de perfil ya resuelta. `null` = sin foto.
  final ImageProvider? imagen;

  /// Abre el visor a pantalla completa. Sólo se dispara si hay foto.
  final VoidCallback onVerFoto;

  /// Abre el selector de origen (cámara / galería).
  final VoidCallback onCambiarFoto;

  /// Diámetro del círculo, sin contar el anillo.
  final double size;

  /// Grosor del anillo translúcido que separa la foto del fondo del hero.
  static const double _anillo = 4;

  /// Lado visual del badge de cámara. Su área táctil es mayor (ver [_Badge]).
  static const double _badge = 30;

  /// Key del área táctil del badge, para verificar su tamaño en los tests.
  static const badgeKey = Key('hero-avatar-badge');

  @override
  Widget build(BuildContext context) {
    final tieneFoto = imagen != null;

    final circulo = Container(
      padding: const EdgeInsets.all(_anillo),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.35),
      ),
      child: Avatar(nombre: nombre, imagen: imagen, size: size),
    );

    return Stack(
      // El área táctil del badge (48dp) desborda el círculo: sin esto se
      // recortaría y volvería a quedar por debajo del mínimo tocable.
      clipBehavior: Clip.none,
      children: [
        if (tieneFoto)
          Semantics(
            button: true,
            label: 'Ver foto de perfil',
            child: GestureDetector(
              onTap: onVerFoto,
              behavior: HitTestBehavior.opaque,
              child: ExcludeSemantics(child: circulo),
            ),
          )
        else
          // Sin foto el círculo comparte la acción del badge: se lo excluye de
          // la semántica para no anunciar dos veces el mismo control.
          ExcludeSemantics(
            child: GestureDetector(
              onTap: onCambiarFoto,
              behavior: HitTestBehavior.opaque,
              child: circulo,
            ),
          ),
        Positioned(
          right: -(AppSpacing.minTapTarget - _badge) / 2,
          bottom: -(AppSpacing.minTapTarget - _badge) / 2,
          child: _Badge(onTap: onCambiarFoto),
        ),
      ],
    );
  }
}

/// Badge de cámara: círculo de 30dp centrado dentro de un área táctil de 48dp.
class _Badge extends StatelessWidget {
  const _Badge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cambiar foto de perfil',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          key: ProfileHeroAvatar.badgeKey,
          width: AppSpacing.minTapTarget,
          height: AppSpacing.minTapTarget,
          child: Center(
            child: Container(
              width: ProfileHeroAvatar._badge,
              height: ProfileHeroAvatar._badge,
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
                boxShadow: AppSpacing.elev1,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.photo_camera_outlined,
                size: 16,
                color: context.colors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
