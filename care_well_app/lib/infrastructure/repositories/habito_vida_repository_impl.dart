import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class HabitoVidaRepositoryImpl implements HabitoVidaRepository {
  final HabitoVidaDatasource _datasource;

  const HabitoVidaRepositoryImpl(this._datasource);

  @override
  Future<List<HabitoVida>> getHabitosByPersona(int personaId) =>
      _datasource.getHabitosByPersona(personaId);

  @override
  Future<void> crearHabito({
    required int personaId,
    required int tipoId,
    required String descripcion,
  }) => _datasource.crearHabito(
    personaId: personaId,
    tipoId: tipoId,
    descripcion: descripcion,
  );

  @override
  Future<void> modificarHabito({
    required int habitoId,
    required int tipoId,
    required String descripcion,
  }) => _datasource.modificarHabito(
    habitoId: habitoId,
    tipoId: tipoId,
    descripcion: descripcion,
  );

  @override
  Future<void> eliminarHabito(int habitoId) =>
      _datasource.eliminarHabito(habitoId);

  @override
  Future<void> crearRealizacion({required int habitoId, String? comentarios}) =>
      _datasource.crearRealizacion(
        habitoId: habitoId,
        comentarios: comentarios,
      );

  @override
  Future<void> modificarRealizacion({
    required int habitoId,
    required int realizacionId,
    String? comentarios,
  }) => _datasource.modificarRealizacion(
    habitoId: habitoId,
    realizacionId: realizacionId,
    comentarios: comentarios,
  );

  @override
  Future<void> eliminarRealizacion({
    required int habitoId,
    required int realizacionId,
  }) => _datasource.eliminarRealizacion(
    habitoId: habitoId,
    realizacionId: realizacionId,
  );
}
