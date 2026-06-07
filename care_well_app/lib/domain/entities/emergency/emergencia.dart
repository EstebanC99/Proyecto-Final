import '../base_entity.dart';
import '../shared/persona.dart';

/// Registro de una emergencia activada para una persona a cargo.
///
/// Cuando un colaborador activa la alerta, se crea una [Emergencia] que
/// notifica a todo el equipo de cuidado.
class Emergencia extends BaseEntity {
  /// Persona que originó la emergencia.
  final Persona persona;

  final DateTime fechaHora;

  /// `true` una vez que el equipo confirmó que la situación fue atendida.
  final bool atendida;

  /// Descripción breve opcional ingresada por quien activó la alerta.
  final String? descripcion;

  const Emergencia({
    required super.id,
    required this.persona,
    required this.fechaHora,
    this.atendida = false,
    this.descripcion,
  });

  @override
  Emergencia copyWith({
    String? id,
    Persona? persona,
    DateTime? fechaHora,
    bool? atendida,
    String? descripcion,
  }) {
    return Emergencia(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      fechaHora: fechaHora ?? this.fechaHora,
      atendida: atendida ?? this.atendida,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
