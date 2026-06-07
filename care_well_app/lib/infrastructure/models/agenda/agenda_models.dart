import 'dart:convert';

/// DTO de [EventoAgenda] para serialización JSON.
class EventoAgendaModel {
  final String id;
  final String personaId;
  final String creadoPorId;
  final String titulo;
  final String? descripcion;

  /// Tipo: 'citaMedica', 'medicacion', 'rehabilitacion', 'control', 'otro'.
  final String tipo;
  final String fechaHoraInicio;
  final String? fechaHoraFin;

  const EventoAgendaModel({
    required this.id,
    required this.personaId,
    required this.creadoPorId,
    required this.titulo,
    this.descripcion,
    required this.tipo,
    required this.fechaHoraInicio,
    this.fechaHoraFin,
  });

  factory EventoAgendaModel.fromJson(Map<String, dynamic> json) {
    return EventoAgendaModel(
      id: json['id'] as String,
      personaId: json['personaId'] as String,
      creadoPorId: json['creadoPorId'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      tipo: json['tipo'] as String,
      fechaHoraInicio: json['fechaHoraInicio'] as String,
      fechaHoraFin: json['fechaHoraFin'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      'creadoPorId': creadoPorId,
      'titulo': titulo,
      if (descripcion != null) 'descripcion': descripcion,
      'tipo': tipo,
      'fechaHoraInicio': fechaHoraInicio,
      if (fechaHoraFin != null) 'fechaHoraFin': fechaHoraFin,
    };
  }

  factory EventoAgendaModel.fromRawJson(String source) =>
      EventoAgendaModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}

/// DTO de [Recordatorio] para serialización JSON.
class RecordatorioModel {
  final String id;
  final String eventoAgendaId;
  final String fechaHoraEnvio;
  final bool enviado;

  const RecordatorioModel({
    required this.id,
    required this.eventoAgendaId,
    required this.fechaHoraEnvio,
    this.enviado = false,
  });

  factory RecordatorioModel.fromJson(Map<String, dynamic> json) {
    return RecordatorioModel(
      id: json['id'] as String,
      eventoAgendaId: json['eventoAgendaId'] as String,
      fechaHoraEnvio: json['fechaHoraEnvio'] as String,
      enviado: (json['enviado'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventoAgendaId': eventoAgendaId,
      'fechaHoraEnvio': fechaHoraEnvio,
      'enviado': enviado,
    };
  }

  factory RecordatorioModel.fromRawJson(String source) =>
      RecordatorioModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}
