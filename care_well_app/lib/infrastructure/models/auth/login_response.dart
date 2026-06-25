import 'package:care_well_app/infrastructure/models/models.dart';

class LoginResponse {
  final String accessToken;
  final DateTime expiracion;
  final String refreshToken;
  final UsuarioModel usuario;

  LoginResponse({
    required this.accessToken,
    required this.expiracion,
    required this.refreshToken,
    required this.usuario,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json["accessToken"],
    expiracion: DateTime.parse(json["expiracion"]),
    refreshToken: json["refreshToken"],
    usuario: UsuarioModel.fromJson(json["usuario"]),
  );

  Map<String, dynamic> toJson() => {
    "accessToken": accessToken,
    "expiracion": expiracion.toIso8601String(),
    "refreshToken": refreshToken,
    "usuario": usuario.toJson(),
  };
}
