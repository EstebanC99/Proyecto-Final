import 'dart:convert';

/// DTO de [Persona] para serialización JSON.
class PersonaModel {
  final String id;
  final String nombre;
  final String apellido;
  final String? documento;
  final String? fechaNacimiento;
  final String? email;
  final String? telefono;
  final String? imagen;

  const PersonaModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.documento,
    this.fechaNacimiento,
    this.email,
    this.telefono,
    this.imagen,
  });

  factory PersonaModel.fromJson(Map<String, dynamic> json) {
    return PersonaModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      documento: json['documento'] as String?,
      fechaNacimiento: json['fechaNacimiento'] as String?,
      email: json['email'] as String?,
      telefono: json['telefono'] as String?,
      imagen: json['imagen'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      if (documento != null) 'documento': documento,
      if (fechaNacimiento != null) 'fechaNacimiento': fechaNacimiento,
      if (email != null) 'email': email,
      if (telefono != null) 'telefono': telefono,
      if (imagen != null) 'imagen': imagen,
    };
  }

  /// Deserializa desde un string JSON.
  factory PersonaModel.fromRawJson(String source) =>
      PersonaModel.fromJson(json.decode(source) as Map<String, dynamic>);

  /// Serializa a un string JSON.
  String toRawJson() => json.encode(toJson());
}
