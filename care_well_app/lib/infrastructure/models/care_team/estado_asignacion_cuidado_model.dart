class EstadoAsignacionCuidadoModel {
  final int id;
  final String descripcion;

  const EstadoAsignacionCuidadoModel({
    required this.id,
    required this.descripcion,
  });

  factory EstadoAsignacionCuidadoModel.fromJson(Map<String, dynamic> json) =>
      EstadoAsignacionCuidadoModel(
        id: json['id'],
        descripcion: json['descripcion'],
      );
}
