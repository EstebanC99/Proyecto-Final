import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class SummaryRepositoryImpl implements SummaryRepository {
  final SummaryDatasource _datasource;

  const SummaryRepositoryImpl(this._datasource);

  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  }) => _datasource.obtenerResumen(
    personaId: personaId,
    forzarActualizacion: forzarActualizacion,
  );
}
