import '../entities/entities.dart';

abstract class AsignacionCuidadoRepository {
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado();

  Future<List<AsignacionCuidado>> obtenerAsignacionesPorPersona(
    int personaCuidadaId,
  );

  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
  });

  Future<Persona> modificarPersonaCargo(int asignacionId, Persona persona);

  Future<void> asignarPersonaEquipoCuidado({
    required int personaCuidadaId,
    required String colaboradorEmail,
    required int rolCuidadoId,
    required List<int> permisosCuidadoIds,
  });

  Future<void> modificarPermisosAsignacion({
    required int asignacionId,
    required List<PermisoCuidado> permisosSeleccionados,
  });

  Future<void> eliminarAsignacion(int asignacionId);

  Future<void> activarAsignacion(int asignacionId);

  Future<void> reactivarAsignacion(int asignacionId);
}
