/// DTO de [EventoBase] para serialización JSON.
class EventoBaseModel {
  final int id;
  final String descripcion;
  final String categoriaEvento;
  final String fechaHora;

  const EventoBaseModel({
    required this.id,
    required this.descripcion,
    required this.categoriaEvento,
    required this.fechaHora,
  });

  factory EventoBaseModel.fromJson(Map<String, dynamic> json) {
    return EventoBaseModel(
      id: json['id'] as int,
      descripcion: json['descripcion'] as String,
      categoriaEvento: json['categoriaEvento'] as String,
      fechaHora: json['fechaHora'] as String,
    );
  }
}
