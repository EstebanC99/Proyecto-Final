import 'dart:convert';

/// DTO de [Usuario] para serialización JSON.
class UsuarioModel {
  final String id;
  final String personaId;
  final String nombreUsuario;
  final String? contrasenaHash;

  /// Estado de la cuenta: 'activo', 'suspendido' o 'eliminado'.
  final String estado;

  const UsuarioModel({
    required this.id,
    required this.personaId,
    required this.nombreUsuario,
    this.contrasenaHash,
    this.estado = 'activo',
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      personaId: json['personaId'] as String,
      nombreUsuario: json['nombreUsuario'] as String,
      contrasenaHash: json['contrasenaHash'] as String?,
      estado: (json['estado'] as String?) ?? 'activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaId': personaId,
      'nombreUsuario': nombreUsuario,
      if (contrasenaHash != null) 'contrasenaHash': contrasenaHash,
      'estado': estado,
    };
  }

  factory UsuarioModel.fromRawJson(String source) =>
      UsuarioModel.fromJson(json.decode(source) as Map<String, dynamic>);

  String toRawJson() => json.encode(toJson());
}
