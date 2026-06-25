import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [HealthRepository] que delega al [HealthDatasource] inyectado.
class HealthRepositoryImpl implements HealthRepository {
  final HealthDatasource _datasource;

  const HealthRepositoryImpl(this._datasource);

  @override
  Future<FichaSalud> getFichaSalud(int personaId) =>
      _datasource.getFichaSalud(personaId);

  @override
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha) =>
      _datasource.guardarFichaSalud(ficha);

  @override
  Future<List<HabitoDeVida>> getHabitosByPersona(int personaId) =>
      _datasource.getHabitosByPersona(personaId);

  @override
  Future<HabitoDeVida> crearHabito(HabitoDeVida habito) =>
      _datasource.crearHabito(habito);

  @override
  Future<HabitoDeVida> actualizarHabito(HabitoDeVida habito) =>
      _datasource.actualizarHabito(habito);

  @override
  Future<void> eliminarHabito(int habitoId) =>
      _datasource.eliminarHabito(habitoId);

  @override
  Future<List<RecomendacionMedica>> getRecomendacionesByPersona(
    int personaId,
  ) => _datasource.getRecomendacionesByPersona(personaId);

  @override
  Future<RecomendacionMedica> crearRecomendacion(
    RecomendacionMedica recomendacion,
  ) => _datasource.crearRecomendacion(recomendacion);

  @override
  Future<RecomendacionMedica> actualizarRecomendacion(
    RecomendacionMedica recomendacion,
  ) => _datasource.actualizarRecomendacion(recomendacion);

  @override
  Future<void> eliminarRecomendacion(int recomendacionId) =>
      _datasource.eliminarRecomendacion(recomendacionId);

  @override
  Future<List<EventoDeSalud>> getEventosSaludByPersona(int personaId) =>
      _datasource.getEventosSaludByPersona(personaId);

  @override
  Future<EventoDeSalud> crearEventoSalud(EventoDeSalud evento) =>
      _datasource.crearEventoSalud(evento);

  @override
  Future<EventoDeSalud> actualizarEventoSalud(EventoDeSalud evento) =>
      _datasource.actualizarEventoSalud(evento);

  @override
  Future<void> eliminarEventoSalud(int eventoId) =>
      _datasource.eliminarEventoSalud(eventoId);

  @override
  Future<List<NotaEvento>> getNotasByEvento(int eventoId) =>
      _datasource.getNotasByEvento(eventoId);

  @override
  Future<NotaEvento> crearNota(NotaEvento nota) => _datasource.crearNota(nota);

  @override
  Future<List<EstadoDeAnimo>> getEstadosAnimoByPersona(int personaId) =>
      _datasource.getEstadosAnimoByPersona(personaId);

  @override
  Future<EstadoDeAnimo> crearEstadoAnimo(EstadoDeAnimo estadoAnimo) =>
      _datasource.crearEstadoAnimo(estadoAnimo);

  @override
  Future<EstadoDeAnimo> actualizarEstadoAnimo(EstadoDeAnimo estadoAnimo) =>
      _datasource.actualizarEstadoAnimo(estadoAnimo);

  @override
  Future<void> eliminarEstadoAnimo(int estadoAnimoId) =>
      _datasource.eliminarEstadoAnimo(estadoAnimoId);
}
