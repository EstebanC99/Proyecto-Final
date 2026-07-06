/// DTO del catálogo [TipoHabito] para serialización JSON.
class TipoHabitoModel {
  final int id;
  final String descripcion;

  const TipoHabitoModel({required this.id, required this.descripcion});

  factory TipoHabitoModel.fromJson(Map<String, dynamic> json) =>
      TipoHabitoModel(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'descripcion': descripcion};
}