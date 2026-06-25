import 'package:care_well_app/infrastructure/models/models.dart';

class UsuarioModel {
  final int id;
  final String nombreUsuario;
  final PersonaModel personaModel;
  final EstadoUsuarioModel estadoModel;

  UsuarioModel({
    required this.id,
    required this.nombreUsuario,
    required this.personaModel,
    required this.estadoModel,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
    id: json["id"],
    nombreUsuario: json["nombreUsuario"],
    personaModel: PersonaModel.fromJson(json["persona"]),
    estadoModel: EstadoUsuarioModel.fromJson(json["estado"]),
  );

  Map<String, dynamic> toJson() => {"id": id, "nombreUsuario": nombreUsuario};
}
