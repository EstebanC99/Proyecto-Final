import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class TipoHabitoVidaRepositoryImpl implements TipoHabitoVidaRepository {
  final TipoHabitoVidaDatasource _datasource;

  const TipoHabitoVidaRepositoryImpl(this._datasource);

  @override
  Future<List<TipoHabitoVida>> obtenerTiposHabitosVida() =>
      _datasource.obtenerTiposHabitosVida();
}
