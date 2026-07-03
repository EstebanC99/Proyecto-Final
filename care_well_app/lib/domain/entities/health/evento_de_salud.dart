import '../base_entity.dart';
import '../shared/entidad_basica.dart';
import 'nota_evento.dart';

/// Tipo de evento de salud (catálogo persistido).
///
/// Los ids provienen del catálogo compartido de tipos de evento
/// ([TiposEventoAgendaConst]).
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
/// Las notas del equipo vienen embebidas en [notas]. Cuando el evento fue
/// generado automáticamente a partir de una ocurrencia de agenda,
/// [fechaOcurrenciaEventoAgenda] indica la fecha/hora de esa ocurrencia.
class EventoDeSalud extends BaseEntity {
  /// Persona a la que corresponde este evento (referencia embebida).
  final EntidadBasica persona;

  final TipoEventoSalud tipo;
  final DateTime fechaHora;
  final String descripcion;

  /// Notas colaborativas asociadas al evento.
  final List<NotaEvento> notas;

  /// Fecha/hora de la ocurrencia de agenda que originó este evento, si aplica.
  final DateTime? fechaOcurrenciaEventoAgenda;

  const EventoDeSalud({
    required super.id,
    required this.persona,
    required this.tipo,
    required this.fechaHora,
    required this.descripcion,
    this.notas = const [],
    this.fechaOcurrenciaEventoAgenda,
  });

  /// `true` si el evento tiene al menos una nota asociada.
  bool get tieneNotas => notas.isNotEmpty;

  /// Cantidad de notas asociadas al evento.
  int get cantidadNotas => notas.length;

  @override
  EventoDeSalud copyWith({
    int? id,
    EntidadBasica? persona,
    TipoEventoSalud? tipo,
    DateTime? fechaHora,
    String? descripcion,
    List<NotaEvento>? notas,
    DateTime? fechaOcurrenciaEventoAgenda,
  }) {
    return EventoDeSalud(
      id: id ?? this.id,
      persona: persona ?? this.persona,
      tipo: tipo ?? this.tipo,
      fechaHora: fechaHora ?? this.fechaHora,
      descripcion: descripcion ?? this.descripcion,
      notas: notas ?? this.notas,
      fechaOcurrenciaEventoAgenda:
          fechaOcurrenciaEventoAgenda ?? this.fechaOcurrenciaEventoAgenda,
    );
  }
}
