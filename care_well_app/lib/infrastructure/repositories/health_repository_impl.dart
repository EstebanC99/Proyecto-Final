import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthDatasource _datasource;

  const HealthRepositoryImpl(this._datasource);

  @override
  Future<FichaSalud> getFichaSalud(int personaId) =>
      _datasource.getFichaSalud(personaId);

  @override
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha) =>
      _datasource.guardarFichaSalud(ficha);

  @override
  Future<List<RecomendacionMedica>> getRecomendacionesByPersona(
    int personaId,
  ) => _datasource.getRecomendacionesByPersona(personaId);

  @override
  Future<RecomendacionMedica> crearRecomendacion(
    RecomendacionMedica recomendacion,
  ) => _datasource.crearRecomendacion(recomendacion);

  @override
  Future<RecomendacionMedica> actualizarRecomendacion(
    RecomendacionMedica recomendacion,
  ) => _datasource.actualizarRecomendacion(recomendacion);

  @override
  Future<void> eliminarRecomendacion(int recomendacionId) =>
      _datasource.eliminarRecomendacion(recomendacionId);
}
