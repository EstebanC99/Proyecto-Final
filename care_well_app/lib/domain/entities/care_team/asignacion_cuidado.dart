import '../base_entity.dart';
import '../shared/persona.dart';
import 'permiso.dart';
import 'rol_cuidado.dart';

/// Estado de una [AsignacionCuidado] (catálogo persistido).
///
/// - id 1: Activa — la asignación está vigente.
/// - id 2: Inactiva — la asignación fue dada de baja.
/// - id 3: Pendiente — invitación enviada, pendiente de aceptación.
class EstadoAsignacion extends BaseEntity {
  final String descripcion;

  const EstadoAsignacion({required super.id, required this.descripcion});

  @override
  EstadoAsignacion copyWith({int? id, String? descripcion}) {
    return EstadoAsignacion(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}

/// Vínculo entre una persona cuidada y un colaborador (responsable o cuidador).
///
/// Registra quién cuida a quién, con qué rol, qué permisos específicos tiene
/// en esta asignación y en qué estado se encuentra.
class AsignacionCuidado extends BaseEntity {
  /// Persona que es cuidada.
  final Persona personaCuidada;

  /// Persona que colabora en el cuidado.
  final Persona personaColaborador;

  /// Rol del colaborador en este equipo de cuidado.
  final RolCuidado rol;

  final EstadoAsignacion estado;
  final DateTime fechaAlta;

  /// Permisos específicos otorgados en esta asignación.
  ///
  /// Los permisos son propios de la asignación y no del rol.
  final List<Permiso> permisos;

  const AsignacionCuidado({
    required super.id,
    required this.personaCuidada,
    required this.personaColaborador,
    required this.rol,
    required this.estado,
    required this.fechaAlta,
    this.permisos = const [],
  });

  @override
  AsignacionCuidado copyWith({
    int? id,
    Persona? personaCuidada,
    Persona? personaColaborador,
    RolCuidado? rol,
    EstadoAsignacion? estado,
    DateTime? fechaAlta,
    List<Permiso>? permisos,
  }) {
    return AsignacionCuidado(
      id: id ?? this.id,
      personaCuidada: personaCuidada ?? this.personaCuidada,
      personaColaborador: personaColaborador ?? this.personaColaborador,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      permisos: permisos ?? this.permisos,
    );
  }
}
