import 'package:care_well_app/domain/entities/entities.dart';

class EventoSalud extends BaseEntity {
  final EntidadBasica persona;
  final TipoEventoSalud tipo;
  final DateTime fechaHora;
  final String descripcion;
  final List<NotaEventoSalud> notas;
  final DateTime? fechaOcurrenciaEventoAgenda;

  const EventoSalud({
    required super.id,
    required this.persona,
    required this.tipo,
    required this.fechaHora,
    required this.descripcion,
    this.notas = const [],
    this.fechaOcurrenciaEventoAgenda,
  });

  bool get tieneNotas => notas.isNotEmpty;
  int get cantidadNotas => notas.length;

  @override
  EventoSalud copyWith({
    int? id,
    EntidadBasica? persona,
    TipoEventoSalud? tipo,
    DateTime? fechaHora,
    String? descripcion,
    List<NotaEventoSalud>? notas,
    DateTime? fechaOcurrenciaEventoAgenda,
  }) {
    return EventoSalud(
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
