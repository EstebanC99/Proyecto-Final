import 'package:care_well_app/domain/entities/entities.dart';

class PersonaEstadoAnimo extends BaseEntity {
  final Persona persona;
  final DateTime fecha;
  final EstadoAnimo estado;
  final String? observaciones;

  const PersonaEstadoAnimo({
    required super.id,
    required this.persona,
    required this.fecha,
    required this.estado,
    this.observaciones,
  });

  @override
  PersonaEstadoAnimo copyWith({
    int? id,
    Persona? persona,
    DateTime? fecha,
    EstadoAnimo? estado,
    String? observaciones,
  }) {
    return PersonaEstadoAnimo(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
