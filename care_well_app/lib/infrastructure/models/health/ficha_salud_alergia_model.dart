class FichaSaludAlergiaModel {
  final int id;
  final String nombre;
  final String reaccion;
  final String? medicamento;

  const FichaSaludAlergiaModel({
    required this.id,
    required this.nombre,
    required this.reaccion,
    this.medicamento,
  });

  factory FichaSaludAlergiaModel.fromJson(Map<String, dynamic> json) {
    return FichaSaludAlergiaModel(
      id: (json['id'] as int?) ?? 0,
      nombre: json['nombre'] as String,
      reaccion: json['reaccion'] as String,
      medicamento: json['medicamento'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'reaccion': reaccion,
    if (medicamento != null) 'medicamento': medicamento,
  };
}
