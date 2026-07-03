import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/agenda/tipo_evento.dart';
import 'package:care_well_app/domain/repositories/tipo_evento_repository.dart';

class TipoEventoRepositoryImpl implements TipoEventoRepository {
  final TipoEventoDatasource _datasource;

  const TipoEventoRepositoryImpl(this._datasource);

  @override
  Future<List<TipoEvento>> obtenerTiposEvento() =>
      _datasource.obtenerTiposEvento();
}
