class RolCuidadoModel {
  final int id;
  final String descripcion;

  const RolCuidadoModel({required this.id, required this.descripcion});

  factory RolCuidadoModel.fromJson(Map<String, dynamic> json) =>
      RolCuidadoModel(id: json['id'], descripcion: json['descripcion']);
}
