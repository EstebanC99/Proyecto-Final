import '../entities/entities.dart';

/// Contrato de repositorio para el ABM de [Persona].
abstract class PersonaRepository {
  /// Retorna la [Persona] con el [id] dado.
  Future<Persona> getById(int id);

  /// Retorna las personas a cargo del usuario con [usuarioId].
  // TODO: evaluar si se elimina cuando todos los flujos usen AsignacionCuidadoRepository.
  Future<List<Persona>> getDependientesByUsuario(int usuarioId);

  /// Crea una nueva [Persona].
  Future<Persona> crear(Persona persona);

  /// Actualiza los datos de una [Persona] existente.
  Future<Persona> actualizar(Persona persona);

  /// Elimina (baja lógica) la [Persona] con [id].
  Future<void> eliminar(int id);
}
