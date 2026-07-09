class PersonaModel {
  final String nombre;
  final String apellido;
  final String documento;
  final DateTime fechaNacimiento;
  final String? email;
  final String? telefono;
  final String? imagen;
  final int id;

  PersonaModel({
    required this.nombre,
    required this.apellido,
    required this.documento,
    required this.fechaNacimiento,
    required this.email,
    required this.telefono,
    required this.imagen,
    required this.id,
  });

  factory PersonaModel.fromJson(Map<String, dynamic> json) => PersonaModel(
    nombre: json["nombre"],
    apellido: json["apellido"],
    documento: json["documento"],
    fechaNacimiento: DateTime.parse(json["fechaNacimiento"]),
    email: json["email"] as String?,
    telefono: json["telefono"] as String?,
    imagen: json["imagen"] as String?,
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "apellido": apellido,
    "documento": documento,
    "fechaNacimiento": fechaNacimiento.toIso8601String(),
    "email": email,
    "telefono": telefono,
    "imagen": imagen,
    "id": id,
  };
}
