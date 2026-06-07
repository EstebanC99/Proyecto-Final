import 'dart:convert';

/// DTO de [Permiso] para serialización JSON.
class PermisoModel {
  final String id;

  /// Código canónico: coincide con [CodigoPermiso] en el dominio.
  final String codigo;
  final String descripcion;

  const PermisoModel({
    required this.id,
    required this.codigo,
    required this.descripcion,
  });

  factory PermisoModel.fromJson(Map<String, dynamic> json) {
    return PermisoModel(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'codigo': codigo, 'descripcion': descripcion};
  }
}

/// DTO de [Rol] para serialización JSON.
class RolModel {
  final String id;

  /// Nombre del rol: 'responsable' o 'cuidador'.
  final String nombre;
  final List<PermisoModel> permisos;

  const RolModel({
    required this.id,
    required this.nombre,
    this.permisos = const [],
  });

  factory RolModel.fromJson(Map<String, dynamic> json) {
    final permisosList = (json['permisos'] as List<dynamic>?) ?? [];
    return RolModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      permisos: permisosList
          .map((e) => PermisoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'permisos': permisos.map((p) => p.toJson()).toList(),
    };
  }
}

/// DTO de [AsignacionCuidado] para serialización JSON.
class AsignacionCuidadoModel {
  final String id;
  final String personaCuidadaId;
  final String personaColaboradorId;
  final String rolId;

  /// Estado: 'activa', 'inactiva' o 'pendiente'.
  final String estado;
  final String fechaAlta;

  const AsignacionCuidadoModel({
    required this.id,
    required this.personaCuidadaId,
    required this.personaColaboradorId,
    required this.rolId,
    required this.estado,
    required this.fechaAlta,
  });

  factory AsignacionCuidadoModel.fromJson(Map<String, dynamic> json) {
    return AsignacionCuidadoModel(
      id: json['id'] as String,
      personaCuidadaId: json['personaCuidadaId'] as String,
      personaColaboradorId: json['personaColaboradorId'] as String,
      rolId: json['rolId'] as String,
      estado: json['estado'] as String,
      fechaAlta: json['fechaAlta'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personaCuidadaId': personaCuidadaId,
      'personaColaboradorId': personaColaboradorId,
      'rolId': rolId,
      'estado': estado,
      'fechaAlta': fechaAlta,
    };
  }

  factory AsignacionCuidadoModel.fromRawJson(String source) =>
      AsignacionCuidadoModel.fromJson(
        json.decode(source) as Map<String, dynamic>,
      );

  String toRawJson() => json.encode(toJson());
}
