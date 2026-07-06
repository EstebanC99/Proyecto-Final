import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class LineaTiempoSaludRepositoryImpl implements LineaTiempoSaludRepository {
  final LineaTiempoSaludDatasource _datasource;

  const LineaTiempoSaludRepositoryImpl(this._datasource);

  @override
  Future<List<EventoBase>> getEventosPorFechas({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) => _datasource.getEventosPorFechas(
    personaId: personaId,
    desde: desde,
    hasta: hasta,
  );
}
