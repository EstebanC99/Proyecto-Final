import 'package:care_well_app/domain/entities/entities.dart';

class Usuario extends BaseEntity {
  final Persona persona;
  final String contrasena;
  final EstadoUsuario estado;

  const Usuario({
    required super.id,
    required this.persona,
    required this.contrasena,
    required this.estado,
  });

  @override
  Usuario copyWith({
    int? id,
    Persona? persona,
    String? contrasena,
    EstadoUsuario? estado,
  }) {
    return Usuario(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      contrasena: contrasena ?? this.contrasena,
      estado: estado ?? this.estado,
    );
  }
}
