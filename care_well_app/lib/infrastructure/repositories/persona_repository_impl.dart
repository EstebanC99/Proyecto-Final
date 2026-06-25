import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [PersonaRepository] que delega al [PersonaDatasource] inyectado.
class PersonaRepositoryImpl implements PersonaRepository {
  final PersonaDatasource _datasource;

  const PersonaRepositoryImpl(this._datasource);

  @override
  Future<Persona> getById(int id) => _datasource.getById(id);

  @override
  Future<List<Persona>> getDependientesByUsuario(int usuarioId) =>
      _datasource.getDependientesByUsuario(usuarioId);

  @override
  Future<Persona> crear(Persona persona) => _datasource.crear(persona);

  @override
  Future<Persona> actualizar(Persona persona) =>
      _datasource.actualizar(persona);

  @override
  Future<void> eliminar(int id) => _datasource.eliminar(id);
}
