import 'package:care_well_app/infrastructure/models/models.dart';

/// DTO de [EventoDeSalud] para serialización JSON.
class EventoSaludModel {
  final int id;
  final EntidadBasicaModel persona;
  final TipoEventoSaludModel tipo;
  final String fechaHora;
  final String descripcion;
  final List<NotaEventoSaludModel> notas;
  final String? fechaOcurrenciaEventoAgenda;

  const EventoSaludModel({
    required this.id,
    required this.persona,
    required this.tipo,
    required this.fechaHora,
    required this.descripcion,
    this.notas = const [],
    this.fechaOcurrenciaEventoAgenda,
  });

  factory EventoSaludModel.fromJson(Map<String, dynamic> json) {
    final notasJson = json['notas'] as List<dynamic>?;
    return EventoSaludModel(
      id: json['id'] as int,
      persona: EntidadBasicaModel.fromJson(
        json['persona'] as Map<String, dynamic>,
      ),
      tipo: TipoEventoSaludModel.fromJson(json['tipo'] as Map<String, dynamic>),
      fechaHora: json['fechaHora'] as String,
      descripcion: json['descripcion'] as String,
      notas:
          notasJson
              ?.map(
                (e) => NotaEventoSaludModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      fechaOcurrenciaEventoAgenda:
          json['fechaOcurrenciaEventoAgenda'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'persona': persona.toJson(),
      'tipo': tipo.toJson(),
      'fechaHora': fechaHora,
      'descripcion': descripcion,
      'notas': notas.map((n) => n.toJson()).toList(),
      if (fechaOcurrenciaEventoAgenda != null)
        'fechaOcurrenciaEventoAgenda': fechaOcurrenciaEventoAgenda,
    };
  }
}
