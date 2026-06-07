import '../entities/entities.dart';

/// Interfaz de datasource para el ABM de [Persona].
abstract class PersonaDatasource {
  /// Retorna la [Persona] con el [id] dado.
  /// Lanza excepción si no existe.
  Future<Persona> getById(String id);

  /// Retorna la lista de personas a cargo del usuario con [usuarioId].
  Future<List<Persona>> getDependientesByUsuario(String usuarioId);

  /// Crea una nueva [Persona] y la retorna con su id generado.
  Future<Persona> crear(Persona persona);

  /// Actualiza los datos de una [Persona] existente.
  Future<Persona> actualizar(Persona persona);

  /// Elimina (baja lógica) la [Persona] con [id].
  Future<void> eliminar(String id);
}
