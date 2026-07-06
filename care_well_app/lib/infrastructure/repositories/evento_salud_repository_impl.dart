import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class EventoSaludRepositoryImpl implements EventoSaludRepository {
  final EventoSaludDatasource _datasource;

  const EventoSaludRepositoryImpl(this._datasource);

  @override
  Future<List<EventoSalud>> getEventosSaludDelMes({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  }) => _datasource.getEventosSaludDelMes(
    personaId: personaId,
    desde: desde,
    hasta: hasta,
  );

  @override
  Future<void> crearEventoSalud({
    required int personaId,
    required int tipoId,
    required DateTime fechaHora,
    required String descripcion,
  }) => _datasource.crearEventoSalud(
    personaId: personaId,
    tipoId: tipoId,
    fechaHora: fechaHora,
    descripcion: descripcion,
  );

  @override
  Future<void> eliminarEventoSalud(int eventoId) =>
      _datasource.eliminarEventoSalud(eventoId);

  @override
  Future<void> agregarNota({
    required int eventoSaludId,
    required String contenido,
  }) => _datasource.agregarNota(
    eventoSaludId: eventoSaludId,
    contenido: contenido,
  );

  @override
  Future<void> modificarNota({
    required int eventoSaludId,
    required int notaId,
    required String contenido,
  }) => _datasource.modificarNota(
    eventoSaludId: eventoSaludId,
    notaId: notaId,
    contenido: contenido,
  );

  @override
  Future<void> eliminarNota({
    required int eventoSaludId,
    required int notaId,
  }) => _datasource.eliminarNota(eventoSaludId: eventoSaludId, notaId: notaId);
}
