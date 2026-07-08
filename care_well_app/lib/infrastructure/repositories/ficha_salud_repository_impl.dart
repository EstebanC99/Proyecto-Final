import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class FichaSaludRepositoryImpl implements FichaSaludRepository {
  final FichaSaludDatasource _datasource;

  const FichaSaludRepositoryImpl(this._datasource);

  @override
  Future<FichaSalud?> getFichaSalud(Persona persona) =>
      _datasource.getFichaSalud(persona);

  @override
  Future<void> guardarFichaSalud(FichaSalud ficha) =>
      _datasource.guardarFichaSalud(ficha);
}
