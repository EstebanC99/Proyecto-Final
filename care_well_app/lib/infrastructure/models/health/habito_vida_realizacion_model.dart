/// DTO de la realización diaria de un hábito de vida.
class HabitoVidaRealizacionModel {
  final int id;
  final String? comentarios;
  final String fechaHoraRealizacion;

  const HabitoVidaRealizacionModel({
    required this.id,
    this.comentarios,
    required this.fechaHoraRealizacion,
  });

  factory HabitoVidaRealizacionModel.fromJson(Map<String, dynamic> json) {
    return HabitoVidaRealizacionModel(
      id: json['id'] as int,
      comentarios: json['comentarios'] as String?,
      fechaHoraRealizacion: json['fechaHoraRealizacion'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (comentarios != null) 'comentarios': comentarios,
    'fechaHoraRealizacion': fechaHoraRealizacion,
  };
}
