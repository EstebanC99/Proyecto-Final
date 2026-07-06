import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

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
