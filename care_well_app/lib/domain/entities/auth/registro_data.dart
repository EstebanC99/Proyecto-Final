/// Objeto de parámetros inmutable con todos los datos necesarios para registrar
/// una nueva cuenta (US-01).
///
/// Agrupa los campos del alta para no arrastrar una firma ancha de parámetros
/// nombrados a lo largo de las capas. Es Dart puro (sin anotaciones de
/// serialización): la conversión a JSON del body vive en `ApiAuthDatasource`.
///
/// - [imagenDocumento] es obligatoria: foto del documento de identidad en base64
///   estándar (sin prefijo data-URI), usada por el backend para validar la
///   identidad contra nombre/apellido/documento.
/// - [imagen] es opcional: foto de perfil en base64 estándar (sin prefijo).
class RegistroData {
  final String nombre;
  final String apellido;
  final String documento;
  final DateTime fechaNacimiento;
  final String email;
  final String? telefono;
  final String contrasena;

  /// Foto del documento de identidad en base64 estándar (obligatoria).
  final String imagenDocumento;

  /// Foto de perfil en base64 estándar (opcional).
  final String? imagen;

  const RegistroData({
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.fechaNacimiento,
    required this.email,
    this.telefono,
    required this.contrasena,
    required this.imagenDocumento,
    this.imagen,
  });
}
