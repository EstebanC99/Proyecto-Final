class PermisoCuidadoModel {
  final int id;
  final String descripcion;

  const PermisoCuidadoModel({required this.id, required this.descripcion});

  factory PermisoCuidadoModel.fromJson(Map<String, dynamic> json) =>
      PermisoCuidadoModel(id: json['id'], descripcion: json['descripcion']);
}
