/// DTO del catálogo [EstadoAnimo] para serialización JSON.
class EstadoAnimoModel {
  final int id;
  final String descripcion;

  const EstadoAnimoModel({required this.id, required this.descripcion});

  factory EstadoAnimoModel.fromJson(Map<String, dynamic> json) =>
      EstadoAnimoModel(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'descripcion': descripcion};
}