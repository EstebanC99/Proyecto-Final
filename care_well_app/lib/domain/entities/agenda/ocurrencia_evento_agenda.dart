import '../base_entity.dart';
import 'tipo_evento.dart';

/// Ocurrencia concreta de un evento de agenda dentro de un rango de fechas.
///
/// Un evento recurrente expande en varias ocurrencias; [eventoAgendaId]
/// identifica el evento base al que pertenece.
class OcurrenciaEventoAgenda extends BaseEntity {
  final int eventoAgendaId;
  final int personaId;
  final String titulo;
  final String? descripcion;
  final TipoEvento tipo;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final bool esRecurrente;
  final bool generarEventoSalud;
  final int? minutosAnticipacionRecordatorio;

  const OcurrenciaEventoAgenda({
    required super.id,
    required this.eventoAgendaId,
    required this.personaId,
    required this.titulo,
    this.descripcion,
    required this.tipo,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.esRecurrente,
    required this.generarEventoSalud,
    this.minutosAnticipacionRecordatorio,
  });

  /// Una ocurrencia solo puede editarse si su inicio aún no pasó.
  bool esEditable([DateTime? ahora]) =>
      fechaHoraInicio.isAfter(ahora ?? DateTime.now());

  @override
  OcurrenciaEventoAgenda copyWith({
    int? id,
    int? eventoAgendaId,
    int? personaId,
    String? titulo,
    String? descripcion,
    TipoEvento? tipo,
    DateTime? fechaHoraInicio,
    DateTime? fechaHoraFin,
    bool? esRecurrente,
    bool? generarEventoSalud,
    int? minutosAnticipacionRecordatorio,
  }) {
    return OcurrenciaEventoAgenda(
      id: id ?? this.id,
      eventoAgendaId: eventoAgendaId ?? this.eventoAgendaId,
      personaId: personaId ?? this.personaId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      tipo: tipo ?? this.tipo,
      fechaHoraInicio: fechaHoraInicio ?? this.fechaHoraInicio,
      fechaHoraFin: fechaHoraFin ?? this.fechaHoraFin,
      esRecurrente: esRecurrente ?? this.esRecurrente,
      generarEventoSalud: generarEventoSalud ?? this.generarEventoSalud,
      minutosAnticipacionRecordatorio:
          minutosAnticipacionRecordatorio ??
          this.minutosAnticipacionRecordatorio,
    );
  }
}
