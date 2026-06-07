import '../auth/usuario.dart';
import '../base_entity.dart';
import '../shared/persona.dart';

/// Tipo de evento registrado en la agenda.
enum TipoEventoAgenda {
  /// Cita médica o consulta con un profesional.
  citaMedica,

  /// Toma de medicación.
  medicacion,

  /// Actividad de rehabilitación o terapia.
  rehabilitacion,

  /// Control o seguimiento de salud.
  control,

  /// Otro tipo de evento no categorizado.
  otro,
}

/// Evento agendado para una persona a cargo.
///
/// [creadoPor] indica el [Usuario] que lo registró (puede ser un
/// responsable o un cuidador con permiso).
class EventoAgenda extends BaseEntity {
  /// Persona a la que pertenece el evento.
  final Persona persona;

  /// Usuario que creó el evento.
  final Usuario creadoPor;

  final String titulo;
  final String? descripcion;
  final TipoEventoAgenda tipo;
  final DateTime fechaHoraInicio;
  final DateTime? fechaHoraFin;

  const EventoAgenda({
    required super.id,
    required this.persona,
    required this.creadoPor,
    required this.titulo,
    this.descripcion,
    required this.tipo,
    required this.fechaHoraInicio,
    this.fechaHoraFin,
  });

  /// Retorna `true` si [fechaHoraInicio] ya pasó respecto de [ahora].
  bool estaVencido([DateTime? ahora]) =>
      !fechaHoraInicio.isAfter(ahora ?? DateTime.now());

  /// Un evento solo puede editarse o eliminarse si aún no venció.
  bool esEditable([DateTime? ahora]) => !estaVencido(ahora);

  @override
  EventoAgenda copyWith({
    String? id,
    Persona? persona,
    Usuario? creadoPor,
    String? titulo,
    String? descripcion,
    TipoEventoAgenda? tipo,
    DateTime? fechaHoraInicio,
    DateTime? fechaHoraFin,
  }) {
    return EventoAgenda(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      creadoPor: creadoPor ?? this.creadoPor,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      fechaHoraInicio: fechaHoraInicio ?? this.fechaHoraInicio,
      fechaHoraFin: fechaHoraFin ?? this.fechaHoraFin,
    );
  }
}
