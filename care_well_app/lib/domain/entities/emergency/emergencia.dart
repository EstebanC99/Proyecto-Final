import '../base_entity.dart';
import '../shared/persona.dart';

/// Registro de una emergencia activada para una persona a cargo.
///
/// Es un registro INMUTABLE del hecho (un log): no se marca como atendida ni
/// se modifica. El aviso al equipo de cuidado lo resuelve el backend con
/// notificaciones push; lo que se garantiza es el registro, no la entrega.
class Emergencia extends BaseEntity {
  /// Persona bajo cuidado para la que se activó la alerta.
  final Persona persona;

  /// Persona que activó la alerta.
  final Persona activador;

  final DateTime fechaHora;

  /// Descripción breve opcional ingresada por quien activó la alerta.
  final String? descripcion;

  const Emergencia({
    required super.id,
    required this.persona,
    required this.activador,
    required this.fechaHora,
    this.descripcion,
  });

  @override
  Emergencia copyWith({
    int? id,
    Persona? persona,
    Persona? activador,
    DateTime? fechaHora,
    String? descripcion,
  }) {
    return Emergencia(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      activador: activador ?? this.activador,
      fechaHora: fechaHora ?? this.fechaHora,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
