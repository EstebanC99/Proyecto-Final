import '../base_entity.dart';
import '../shared/persona.dart';

/// Tipo de evento de salud (catálogo persistido).
///
/// - id 1: Cita o consulta médica.
/// - id 2: Hospitalización o internación.
/// - id 3: Medicación administrada o ajuste de dosis.
/// - id 4: Cirugía o procedimiento quirúrgico.
/// - id 5: Tratamiento en curso (fisioterapia, rehabilitación, etc.).
/// - id 6: Evento de bienestar general.
/// - id 7: Síntoma percibido por el dependiente o el cuidador.
/// - id 8: Diagnóstico médico.
/// - id 9: Aplicación de vacuna.
/// - id 10: Otro evento de salud no categorizado.
class TipoEventoSalud extends BaseEntity {
  final String descripcion;

  const TipoEventoSalud({required super.id, required this.descripcion});

  @override
  TipoEventoSalud copyWith({int? id, String? descripcion}) {
    return TipoEventoSalud(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
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
    int? id,
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
