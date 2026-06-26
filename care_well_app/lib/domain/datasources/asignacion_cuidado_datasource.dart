import 'package:care_well_app/domain/entities/entities.dart';

abstract class AsignacionCuidadoDatasource {
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
  });

  Future<Persona> modificarPersonaCargo(int asignacionId, Persona persona);

  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado();

  Future<void> eliminarAsignacion(int asignacionId);

  Future<void> reactivarAsignacion(int asignacionId);
}
