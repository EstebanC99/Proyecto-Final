import '../entities/entities.dart';

abstract class AsignacionCuidadoRepository {
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
  });

  /// Modifica los datos de la persona cuidada identificada por [asignacionId].
  ///
  /// El backend valida los permisos del usuario logueado sobre la asignación
  /// antes de aplicar los cambios. Retorna la [Persona] actualizada.
  Future<Persona> modificarPersonaCargo(int asignacionId, Persona persona);

  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado();
}
