import 'package:flutter/material.dart';

import '../../../config/theme/app_palette.dart';
import 'avatar.dart';

/// Avatar editable: un [Avatar] con un badge de cámara superpuesto que indica
/// que se puede tocar para cambiar la foto.
///
/// La lógica de selección/captura vive en el `onTap` provisto por el padre
/// (típicamente `pickImageAsBase64`).
class EditableAvatar extends StatelessWidget {
  const EditableAvatar({
    super.key,
    required this.nombre,
    required this.onTap,
    this.imagen,
    this.size = 80,
  });

  /// Nombre para el fallback de inicial.
  final String nombre;

  /// Imagen de preview actual. Si es `null` se muestra la inicial.
  final ImageProvider? imagen;

  /// Diámetro del avatar en dp. Por defecto 80.
  final double size;

  /// Acción al tocar (mostrar hoja de origen, elegir imagen, etc.).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.34;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Avatar(nombre: nombre, imagen: imagen, size: size),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.surface, width: 2),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.photo_camera_outlined,
                size: badgeSize * 0.55,
                color: context.colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
