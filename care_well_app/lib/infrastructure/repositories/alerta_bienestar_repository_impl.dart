import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class AlertaBienestarRepositoryImpl implements AlertaBienestarRepository {
  final AlertaBienestarDatasource _datasource;

  const AlertaBienestarRepositoryImpl(this._datasource);

  @override
  Future<List<AlertaBienestar>> getAlertasBienestar(Persona persona) =>
      _datasource.getAlertasBienestar(persona);
}
