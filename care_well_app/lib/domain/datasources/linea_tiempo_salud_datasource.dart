import 'package:care_well_app/domain/entities/health/evento_base.dart';

abstract class LineaTiempoSaludDatasource {
  Future<List<EventoBase>> getEventosPorFechas({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  });
}
