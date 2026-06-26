import '../base_entity.dart';

class Persona extends BaseEntity {
  final String nombre;
  final String apellido;
  final String documento;
  final DateTime fechaNacimiento;
  final String? email;
  final String? telefono;
  final String? imagen;

  const Persona({
    required super.id,
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.fechaNacimiento,
    this.email,
    this.telefono,
    this.imagen,
  });

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
      email: email,
      telefono: telefono,
      imagen: imagen,
    );
  }
}
