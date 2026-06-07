import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Avatar circular con la inicial de un nombre.
///
/// A diferencia de [ProfileAvatar], acepta un [backgroundColor] configurable.
/// Por defecto usa [AppColors.primaryContainer].
class AvatarInitial extends StatelessWidget {
  const AvatarInitial({
    super.key,
    required this.nombre,
    this.size = 44,
    this.backgroundColor,
    this.textColor,
  });

  /// Nombre del que se extrae la inicial (primera letra).
  final String nombre;

  /// Diámetro del círculo en dp. Por defecto 44.
  final double size;

  /// Color de fondo del círculo. Por defecto [AppColors.primaryContainer].
  final Color? backgroundColor;

  /// Color del texto de la inicial. Por defecto [AppColors.onPrimaryContainer].
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    final fontSize = size * 0.42;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryContainer,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor ?? AppColors.onPrimaryContainer,
        ),
      ),
    );
  }
}
