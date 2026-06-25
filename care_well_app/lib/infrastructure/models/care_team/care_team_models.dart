/// DTO de Persona tal como llega en el JSON del backend (dentro de
/// [AsignacionCuidadoApiModel], campos `persona` y `colaborador`).
class PersonaApiModel {
  final int id;
  final String nombre;
  final String apellido;
  final String? documento;
  final String? fechaNacimiento;
  final String? email;
  final String? telefono;
  final String? imagenPath;

  const PersonaApiModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    this.documento,
    this.fechaNacimiento,
    this.email,
    this.telefono,
    this.imagenPath,
  });

  factory PersonaApiModel.fromJson(Map<String, dynamic> json) =>
      PersonaApiModel(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        apellido: json['apellido'] as String,
        documento: json['documento'] as String?,
        fechaNacimiento: json['fechaNacimiento'] as String?,
        email: json['email'] as String?,
        telefono: json['telefono'] as String?,
        imagenPath: json['imagenPath'] as String?,
      );
}

/// DTO genérico para ítems de catálogo: [rol], [estado] y cada elemento
/// de la lista [permisos] dentro de [AsignacionCuidadoApiModel].
class CatalogoItemModel {
  final int id;
  final String descripcion;

  const CatalogoItemModel({required this.id, required this.descripcion});

  factory CatalogoItemModel.fromJson(Map<String, dynamic> json) =>
      CatalogoItemModel(
        id: json['id'] as int,
        descripcion: json['descripcion'] as String,
      );
}

/// DTO principal de la respuesta del endpoint
/// `GET /api/AdministrarEquipoCuidado/obtener-mis-asignaciones`.
class AsignacionCuidadoApiModel {
  final int id;
  final PersonaApiModel persona;
  final PersonaApiModel colaborador;
  final CatalogoItemModel rol;
  final CatalogoItemModel estado;
  final String fechaAlta;
  final List<CatalogoItemModel> permisos;

  const AsignacionCuidadoApiModel({
    required this.id,
    required this.persona,
    required this.colaborador,
    required this.rol,
    required this.estado,
    required this.fechaAlta,
    this.permisos = const [],
  });

  factory AsignacionCuidadoApiModel.fromJson(Map<String, dynamic> json) {
    final permisosList = (json['permisos'] as List<dynamic>?) ?? [];
    return AsignacionCuidadoApiModel(
      id: json['id'] as int,
      persona: PersonaApiModel.fromJson(
        json['persona'] as Map<String, dynamic>,
      ),
      colaborador: PersonaApiModel.fromJson(
        json['colaborador'] as Map<String, dynamic>,
      ),
      rol: CatalogoItemModel.fromJson(json['rol'] as Map<String, dynamic>),
      estado: CatalogoItemModel.fromJson(
        json['estado'] as Map<String, dynamic>,
      ),
      fechaAlta: json['fechaAlta'] as String,
      permisos: permisosList
          .map((e) => CatalogoItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
