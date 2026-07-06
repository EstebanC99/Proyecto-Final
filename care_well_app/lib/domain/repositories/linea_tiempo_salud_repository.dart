import 'package:care_well_app/domain/entities/entities.dart';

abstract class LineaTiempoSaludRepository {
    Future<List<EventoBase>> getEventosPorFechas({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  });
}