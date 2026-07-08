class FichaSaludEnfermedadModel {
  final int id;
  final String nombre;
  final bool vigente;
  final String? observacion;

  const FichaSaludEnfermedadModel({
    required this.id,
    required this.nombre,
    required this.vigente,
    this.observacion,
  });

  factory FichaSaludEnfermedadModel.fromJson(Map<String, dynamic> json) {
    return FichaSaludEnfermedadModel(
      id: (json['id'] as int?) ?? 0,
      nombre: json['nombre'] as String,
      vigente: json['vigente'] as bool,
      observacion: json['observacion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'vigente': vigente,
    if (observacion != null) 'observacion': observacion,
  };
}
