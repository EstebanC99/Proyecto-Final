import '../base_entity.dart';
import '../shared/persona.dart';
import 'rol.dart';

/// Estado de una [AsignacionCuidado].
enum EstadoAsignacion {
  /// La asignación está activa y vigente.
  activa,

  /// La asignación fue dada de baja.
  inactiva,

  /// Invitación enviada, pendiente de aceptación del colaborador.
  pendiente,
}

/// Vínculo entre una persona cuidada y un colaborador (responsable o cuidador).
///
/// Registra quién cuida a quién, con qué rol y en qué estado.
class AsignacionCuidado extends BaseEntity {
  /// Persona que es cuidada.
  final Persona personaCuidada;

  /// Persona que colabora en el cuidado.
  final Persona personaColaborador;

  /// Rol asignado al colaborador.
  final Rol rol;

  final EstadoAsignacion estado;
  final DateTime fechaAlta;

  const AsignacionCuidado({
    required super.id,
    required this.personaCuidada,
    required this.personaColaborador,
    required this.rol,
    required this.estado,
    required this.fechaAlta,
  });

  @override
  AsignacionCuidado copyWith({
    String? id,
    Persona? personaCuidada,
    Persona? personaColaborador,
    Rol? rol,
    EstadoAsignacion? estado,
    DateTime? fechaAlta,
  }) {
    return AsignacionCuidado(
      id: id ?? this.id,
      personaCuidada: personaCuidada ?? this.personaCuidada,
      personaColaborador: personaColaborador ?? this.personaColaborador,
      rol: rol ?? this.rol,
      estado: estado ?? this.estado,
      fechaAlta: fechaAlta ?? this.fechaAlta,
    );
  }
}
