import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shared/personas_providers.dart';
import 'avatar.dart';

/// Avatar de una persona que resuelve su imagen de perfil desde el backend
/// (por `personaId`) y delega el render en [Avatar].
///
/// La imagen se obtiene vía [personaImagenProvider]. Mientras carga —o si la
/// persona no tiene imagen (404) o hay un error— se muestra el fallback de
/// iniciales de [Avatar]: "cargando" se trata igual que "sin imagen" para
/// evitar spinners intrusivos.
class PersonaAvatar extends ConsumerWidget {
  const PersonaAvatar({
    super.key,
    required this.personaId,
    required this.nombre,
    this.size = 44,
    this.backgroundColor,
    this.textColor,
  });

  /// Id de la persona cuya imagen de perfil se solicita.
  final int personaId;

  /// Nombre del que se extrae la inicial como fallback.
  final String nombre;

  /// Diámetro del círculo en dp. Por defecto 44.
  final double size;

  /// Color de fondo del círculo (solo aplica al fallback de inicial).
  final Color? backgroundColor;

  /// Color del texto de la inicial.
  final Color? textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(personaImagenProvider(personaId)).value;

    return Avatar(
      nombre: nombre,
      imagen: bytes != null ? MemoryImage(bytes) : null,
      size: size,
      backgroundColor: backgroundColor,
      textColor: textColor,
    );
  }
}
