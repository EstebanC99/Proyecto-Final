import 'dart:convert';

/// DTO del catálogo [TipoEventoAgenda] para serialización JSON.
class TipoEventoAgendaModel {
  final int id;
  final String descripcion;

  const TipoEventoAgendaModel({required this.id, required this.descripcion});

  factory TipoEventoAgendaModel.fromJson(Map<String, dynamic> json) =>
      TipoEventoAgendaModel(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'descripcion': descripcion};
}

/// DTO de [EventoAgenda] para serialización JSON.
class EventoAgendaModel {
  final int id;
  final int personaId;
  final int creadoPorId;
  final String titulo;
  final String? descripcion;

  /// Tipo como objeto catálogo.
  final TipoEventoAgendaModel tipo;
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
      id: json['id'] as int,
      personaId: json['personaId'] as int,
      creadoPorId: json['creadoPorId'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String?,
      tipo: TipoEventoAgendaModel.fromJson(
        json['tipo'] as Map<String, dynamic>,
      ),
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
      'tipo': tipo.toJson(),
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
  final int id;
  final int eventoAgendaId;
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
      id: json['id'] as int,
      eventoAgendaId: json['eventoAgendaId'] as int,
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
