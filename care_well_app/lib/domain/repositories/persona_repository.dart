import 'package:care_well_app/domain/entities/entities.dart';

abstract class PersonaRepository {
  Future<Persona> getById(int id);

  // TODO: evaluar si se elimina cuando todos los flujos usen AsignacionCuidadoRepository.
  Future<List<Persona>> getDependientesByUsuario(int usuarioId);

  Future<Persona> crear(Persona persona);

  Future<Persona> actualizar(Persona persona);

  Future<void> eliminar(int id);
}
