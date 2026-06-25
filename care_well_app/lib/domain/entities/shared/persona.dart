import '../base_entity.dart';

/// Entidad central del dominio: representa a cualquier individuo registrado.
///
/// Una Persona puede existir sin credenciales de acceso (la registran
/// responsables o cuidadores cuando el dependiente no puede usar la app).
class Persona extends BaseEntity {
  final String nombre;
  final String apellido;

  /// Número de documento (DNI u equivalente).
  final String? documento;

  final DateTime? fechaNacimiento;
  final String? email;

  /// Número de teléfono de contacto.
  final String? telefono;

  /// URL o path local de la imagen de perfil.
  final String? imagen;

  const Persona({
    required super.id,
    required this.nombre,
    required this.apellido,
    this.documento,
    this.fechaNacimiento,
    this.email,
    this.telefono,
    this.imagen,
  });

  /// Nombre completo formateado.
  String get nombreCompleto => '$nombre $apellido';

  @override
  Persona copyWith({
    int? id,
    String? nombre,
    String? apellido,
    String? documento,
    DateTime? fechaNacimiento,
    String? email,
    String? telefono,
    String? imagen,
  }) {
    return Persona(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      documento: documento ?? this.documento,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      imagen: imagen ?? this.imagen,
    );
  }
}
