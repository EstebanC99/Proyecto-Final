/// DTO del catálogo [TipoEventoSalud] para serialización JSON.
class TipoEventoSaludModel {
  final int id;
  final String descripcion;

  const TipoEventoSaludModel({required this.id, required this.descripcion});

  factory TipoEventoSaludModel.fromJson(Map<String, dynamic> json) =>
      TipoEventoSaludModel(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'descripcion': descripcion};
}
