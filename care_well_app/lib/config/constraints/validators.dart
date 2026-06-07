// Funciones de validación puras para formularios de la app.
// No dependen de Flutter (solo Dart) para poder ser testeadas de forma unitaria.
// Retornan null si el valor es válido, o un String con el mensaje de error.

/// Valida que [value] sea un email con formato correcto.
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresá tu email.';
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!regex.hasMatch(value.trim())) return 'Ingresá un email válido.';
  return null;
}

/// Valida que [value] sea una contraseña con al menos 8 caracteres.
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Ingresá una contraseña.';
  if (value.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres.';
  }
  return null;
}

/// Valida que [value] coincida exactamente con [other].
///
/// Usar para el campo "Confirmar contraseña".
String? validatePasswordMatch(String? value, String other) {
  if (value == null || value.isEmpty) return 'Confirmá tu contraseña.';
  if (value != other) return 'Las contraseñas no coinciden.';
  return null;
}

/// Valida que [value] sea un nombre válido (requerido, mínimo 2 caracteres).
String? validateNombre(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresá tu nombre.';
  if (value.trim().length < 2) {
    return 'El nombre debe tener al menos 2 caracteres.';
  }
  return null;
}

/// Valida que [value] sea un apellido válido (requerido, mínimo 2 caracteres).
String? validateApellido(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresá tu apellido.';
  if (value.trim().length < 2) {
    return 'El apellido debe tener al menos 2 caracteres.';
  }
  return null;
}

/// Valida un número de teléfono: opcional (puede ser null/empty) o con 7–20 dígitos.
///
/// Acepta caracteres comunes de formato: +, -, espacios, paréntesis.
String? validateTelefono(String? value) {
  if (value == null || value.trim().isEmpty) return null; // campo opcional
  final soloDigitos = value.replaceAll(RegExp(r'[\s\-+().]'), '');
  if (soloDigitos.length < 7 || soloDigitos.length > 20) {
    return 'Ingresá un teléfono válido.';
  }
  if (!RegExp(r'^\d+$').hasMatch(soloDigitos)) {
    return 'Ingresá un teléfono válido.';
  }
  return null;
}

/// Valida que [value] sea un número de DNI argentino válido (7 u 8 dígitos).
///
/// Acepta el número con o sin puntos/guiones. El campo es requerido.
String? validateDocumento(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingresá el documento.';
  final digits = value.trim().replaceAll(RegExp(r'\D'), '');
  if (digits.length < 7 || digits.length > 8) {
    return 'Ingresá un DNI válido (7-8 dígitos).';
  }
  return null;
}

/// Valida que [value] sea un nombre de usuario válido:
/// requerido, mínimo 3 caracteres, sin espacios.
String? validateNombreUsuario(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Ingresá un nombre de usuario.';
  }
  if (value.contains(' ')) {
    return 'El nombre de usuario no puede contener espacios.';
  }
  if (value.length < 3) {
    return 'El nombre de usuario debe tener al menos 3 caracteres.';
  }
  return null;
}
