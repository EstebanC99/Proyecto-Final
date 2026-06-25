class EstadoUsuarioModel {
  final int id;
  final String descripcion;

  EstadoUsuarioModel({required this.id, required this.descripcion});

  factory EstadoUsuarioModel.fromJson(Map<String, dynamic> json) =>
      EstadoUsuarioModel(id: json["id"], descripcion: json["descripcion"]);

  Map<String, dynamic> toJson() => {"id": id, "descripcion": descripcion};
}
