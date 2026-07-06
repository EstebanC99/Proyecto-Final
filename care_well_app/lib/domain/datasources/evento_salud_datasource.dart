import 'package:care_well_app/domain/entities/entities.dart';

abstract class EventoSaludDatasource {
  Future<List<EventoSalud>> getEventosSaludDelMes({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  });

  Future<void> crearEventoSalud({
    required int personaId,
    required int tipoId,
    required DateTime fechaHora,
    required String descripcion,
  });

  Future<void> eliminarEventoSalud(int eventoId);

  Future<void> agregarNota({
    required int eventoSaludId,
    required String contenido,
  });

  Future<void> modificarNota({
    required int eventoSaludId,
    required int notaId,
    required String contenido,
  });

  Future<void> eliminarNota({required int eventoSaludId, required int notaId});
}
