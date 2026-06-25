import '../base_entity.dart';
import '../shared/persona.dart';
import 'evento_de_salud.dart';

/// Estado de ánimo (catálogo persistido).
///
/// - id 1: Muy bien.
/// - id 2: Bien.
/// - id 3: Regular.
/// - id 4: Mal.
/// - id 5: Muy mal.
class EstadoAnimo extends BaseEntity {
  final String descripcion;

  const EstadoAnimo({required super.id, required this.descripcion});

  @override
  EstadoAnimo copyWith({int? id, String? descripcion}) {
    return EstadoAnimo(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}

/// Estado de ánimo registrado para una persona en un momento dado.
class EstadoDeAnimo extends BaseEntity {
  /// Persona a la que corresponde este estado de ánimo.
  final Persona persona;

  /// Evento de salud relacionado (opcional).
  final EventoDeSalud? eventoDeSalud;

  final DateTime fecha;
  final EstadoAnimo estado;

  /// Observaciones o contexto adicional.
  final String? observaciones;

  const EstadoDeAnimo({
    required super.id,
    required this.persona,
    this.eventoDeSalud,
    required this.fecha,
    required this.estado,
    this.observaciones,
  });

  @override
  EstadoDeAnimo copyWith({
    int? id,
    Persona? persona,
    EventoDeSalud? eventoDeSalud,
    DateTime? fecha,
    EstadoAnimo? estado,
    String? observaciones,
  }) {
    return EstadoDeAnimo(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      eventoDeSalud: eventoDeSalud ?? this.eventoDeSalud,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
