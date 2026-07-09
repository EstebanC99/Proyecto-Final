import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../config/theme/app_colors.dart';

/// Decodifica una imagen en base64 estándar (sin prefijo data-URI) a un
/// [ImageProvider] utilizable por Flutter.
///
/// Devuelve `null` cuando [base64Str] es `null` o está vacío, o si la cadena
/// no es un base64 válido (defensivo: evita romper la UI ante datos corruptos).
ImageProvider? imageProviderFromBase64(String? base64Str) {
  if (base64Str == null || base64Str.isEmpty) return null;
  try {
    return MemoryImage(base64Decode(base64Str));
  } on FormatException {
    return null;
  }
}

/// Avatar circular unificado de la app.
///
/// Si [imagen] no es `null`, muestra la imagen recortada en círculo. En caso
/// contrario, muestra la inicial de [nombre] sobre un fondo de color.
///
/// Reemplaza a los antiguos `ProfileAvatar` y `AvatarInitial`, y al
/// `CircleAvatar` inline del selector de contexto.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.nombre,
    this.imagen,
    this.size = 44,
    this.backgroundColor,
    this.textColor,
  });

  /// Nombre del que se extrae la inicial (primera letra) como fallback.
  final String nombre;

  /// Imagen de perfil. Si es `null` se muestra la inicial de [nombre].
  final ImageProvider? imagen;

  /// Diámetro del círculo en dp. Por defecto 44.
  final double size;

  /// Color de fondo del círculo (solo aplica al fallback de inicial).
  /// Por defecto [AppColors.primaryContainer].
  final Color? backgroundColor;

  /// Color del texto de la inicial. Por defecto [AppColors.onPrimaryContainer].
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    if (imagen != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imagen!, fit: BoxFit.cover),
        ),
      );
    }

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
