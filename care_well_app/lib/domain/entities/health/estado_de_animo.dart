import '../base_entity.dart';
import '../shared/persona.dart';
import 'evento_de_salud.dart';

/// Estado de ánimo registrado para una persona.
enum EstadoAnimoEnum { muyBien, bien, regular, mal, muyMal }

/// Estado de ánimo registrado para una persona en un momento dado.
class EstadoDeAnimo extends BaseEntity {
  /// Persona a la que corresponde este estado de ánimo.
  final Persona persona;

  /// Evento de salud relacionado (opcional).
  final EventoDeSalud? eventoDeSalud;

  final DateTime fecha;
  final EstadoAnimoEnum estado;

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
    String? id,
    Persona? persona,
    EventoDeSalud? eventoDeSalud,
    DateTime? fecha,
    EstadoAnimoEnum? estado,
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
