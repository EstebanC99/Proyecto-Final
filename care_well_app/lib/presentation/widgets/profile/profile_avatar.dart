import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Avatar circular que muestra la inicial del nombre del usuario.
///
/// Fondo [AppColors.primaryContainer], inicial en [AppColors.onPrimaryContainer].
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.nombre, this.size = 80});

  /// Nombre del usuario. Se usa la primera letra como inicial.
  final String nombre;

  /// Diámetro del círculo en dp. Por defecto 80.
  final double size;

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    final fontSize = size * 0.45;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.onPrimaryContainer,
        ),
      ),
    );
  }
}
