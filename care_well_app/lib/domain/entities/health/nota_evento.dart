import '../base_entity.dart';
import '../shared/persona.dart';

/// Nota colaborativa registrada por un miembro del equipo sobre un [EventoDeSalud].
class NotaEvento extends BaseEntity {
  /// ID del evento de salud al que pertenece esta nota.
  final String eventoSaludId;

  /// Persona que redactó la nota.
  final Persona autor;

  /// Fecha y hora en que se registró la nota.
  final DateTime fechaHora;

  /// Contenido de texto libre de la nota.
  final String contenido;

  const NotaEvento({
    required super.id,
    required this.eventoSaludId,
    required this.autor,
    required this.fechaHora,
    required this.contenido,
  });

  @override
  NotaEvento copyWith({
    String? id,
    String? eventoSaludId,
    Persona? autor,
    DateTime? fechaHora,
    String? contenido,
  }) {
    return NotaEvento(
      id: id ?? this.id,
      eventoSaludId: eventoSaludId ?? this.eventoSaludId,
      autor: autor ?? this.autor,
      fechaHora: fechaHora ?? this.fechaHora,
      contenido: contenido ?? this.contenido,
    );
  }
}
