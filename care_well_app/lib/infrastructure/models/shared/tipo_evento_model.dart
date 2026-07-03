class TipoEventoModel {
  final int id;
  final String descripcion;
  final bool agendable;

  const TipoEventoModel({
    required this.id,
    required this.descripcion,
    this.agendable = true,
  });

  factory TipoEventoModel.fromJson(Map<String, dynamic> json) =>
      TipoEventoModel(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
        agendable: (json['agendable'] as bool?) ?? true,
      );
}
