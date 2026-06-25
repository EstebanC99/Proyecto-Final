import '../base_entity.dart';
import '../shared/persona.dart';

/// Recomendación médica recibida por una persona.
class RecomendacionMedica extends BaseEntity {
  /// Persona que recibió la recomendación.
  final Persona persona;

  final String descripcion;
  final DateTime fecha;

  /// Nombre del profesional que emitió la recomendación.
  final String profesional;

  const RecomendacionMedica({
    required super.id,
    required this.persona,
    required this.descripcion,
    required this.fecha,
    required this.profesional,
  });

  @override
  RecomendacionMedica copyWith({
    int? id,
    Persona? persona,
    String? descripcion,
    DateTime? fecha,
    String? profesional,
  }) {
    return RecomendacionMedica(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      profesional: profesional ?? this.profesional,
    );
  }
}
