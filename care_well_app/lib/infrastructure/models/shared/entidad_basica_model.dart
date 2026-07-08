/// DTO de una referencia embebida `{id, descripcion}`.
class EntidadBasicaModel {
  final int id;
  final String descripcion;

  const EntidadBasicaModel({required this.id, required this.descripcion});

  factory EntidadBasicaModel.fromJson(Map<String, dynamic> json) =>
      EntidadBasicaModel(
        id: json['id'] as int,
        descripcion: (json['descripcion'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'descripcion': descripcion};
}
