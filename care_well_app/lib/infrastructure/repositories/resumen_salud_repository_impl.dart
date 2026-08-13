import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class ResumenSaludRepositoryImpl implements ResumenSaludRepository {
  final ResumenSaludDatasource _datasource;

  const ResumenSaludRepositoryImpl(this._datasource);

  @override
  Future<ResumenSalud> getResumenSalud(Persona persona) =>
      _datasource.getResumenSalud(persona);
}
