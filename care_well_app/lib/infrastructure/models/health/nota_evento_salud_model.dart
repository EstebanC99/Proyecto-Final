import 'dart:convert';

import 'package:care_well_app/infrastructure/models/models.dart';

/// DTO de [NotaEvento] para serialización JSON.
class NotaEventoSaludModel {
  final int id;
  final int eventoSaludId;

  /// Autor como referencia embebida `{id, descripcion}`.
  final EntidadBasicaModel autor;
  final String fechaHora;
  final String contenido;

  const NotaEventoSaludModel({
    required this.id,
    required this.eventoSaludId,
    required this.autor,
    required this.fechaHora,
    required this.contenido,
  });

  factory NotaEventoSaludModel.fromJson(Map<String, dynamic> json) {
    return NotaEventoSaludModel(
      id: json['id'] as int,
      eventoSaludId: (json['eventoSaludId'] as int?) ?? 0,
      autor: EntidadBasicaModel.fromJson(json['autor'] as Map<String, dynamic>),
      fechaHora: json['fechaHora'] as String,
      contenido: json['contenido'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventoSaludId': eventoSaludId,
      'autor': autor.toJson(),
      'fechaHora': fechaHora,
      'contenido': contenido,
    };
  }

  factory NotaEventoSaludModel.fromRawJson(String source) =>
      NotaEventoSaludModel.fromJson(
        json.decode(source) as Map<String, dynamic>,
      );

  String toRawJson() => json.encode(toJson());
}
