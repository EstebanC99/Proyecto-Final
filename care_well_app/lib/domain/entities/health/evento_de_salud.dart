import '../base_entity.dart';
import '../shared/persona.dart';

/// Tipo de evento de salud.
enum TipoEventoSalud {
  /// Cita o consulta médica.
  citaMedica,

  /// Hospitalización o internación.
  hospitalizacion,

  /// Medicación administrada o ajuste de dosis.
  medicacion,

  /// Cirugía o procedimiento quirúrgico.
  cirugia,

  /// Tratamiento en curso (fisioterapia, rehabilitación, etc.).
  tratamiento,

  /// Evento de bienestar general.
  bienestar,

  /// Síntoma percibido por el dependiente o el cuidador.
  sintoma,

  /// Diagnóstico médico.
  diagnostico,

  /// Aplicación de vacuna.
  vacuna,

  /// Otro evento de salud no categorizado.
  otro,
}

/// Evento clínico registrado para una persona.
///
/// Las notas adicionales se gestionan como entidades [NotaEvento] separadas,
/// alineado con el modelo de dominio del backend.
class EventoDeSalud extends BaseEntity {
  /// Persona a la que corresponde este evento de salud.
  final Persona persona;

  final TipoEventoSalud tipo;
  final DateTime fecha;
  final String descripcion;

  const EventoDeSalud({
    required super.id,
    required this.persona,
    required this.tipo,
    required this.fecha,
    required this.descripcion,
  });

  @override
  EventoDeSalud copyWith({
    String? id,
    Persona? persona,
    TipoEventoSalud? tipo,
    DateTime? fecha,
    String? descripcion,
  }) {
    return EventoDeSalud(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}
