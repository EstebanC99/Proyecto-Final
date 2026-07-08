class FichaSaludAntecedenteModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String vinculoFamiliar;

  const FichaSaludAntecedenteModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.vinculoFamiliar,
  });

  factory FichaSaludAntecedenteModel.fromJson(Map<String, dynamic> json) {
    return FichaSaludAntecedenteModel(
      id: (json['id'] as int?) ?? 0,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      vinculoFamiliar: json['vinculoFamiliar'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'vinculoFamiliar': vinculoFamiliar,
  };
}
