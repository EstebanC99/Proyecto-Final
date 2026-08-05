import '../shared/persona_model.dart';

/// DTO de lectura de una emergencia.
///
/// Es solo de lectura a propósito: el cliente nunca envía una emergencia
/// completa (activar manda únicamente `{personaID, descripcion}`), así que no
/// necesita `toJson`.
class EmergenciaModel {
  final int id;
  final PersonaModel persona;
  final PersonaModel activador;

  /// ISO-8601 sin offset (hora local del servidor), como el resto de la API.
  final String fechaHora;

  final String? descripcion;

  const EmergenciaModel({
    required this.id,
    required this.persona,
    required this.activador,
    required this.fechaHora,
    this.descripcion,
  });

  factory EmergenciaModel.fromJson(Map<String, dynamic> json) {
    return EmergenciaModel(
      id: json['id'] as int,
      persona: PersonaModel.fromJson(json['persona'] as Map<String, dynamic>),
      activador: PersonaModel.fromJson(
        json['activador'] as Map<String, dynamic>,
      ),
      fechaHora: json['fechaHora'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }
}
