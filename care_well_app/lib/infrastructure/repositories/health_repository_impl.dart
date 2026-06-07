import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [HealthRepository] que delega al [HealthDatasource] inyectado.
class HealthRepositoryImpl implements HealthRepository {
  final HealthDatasource _datasource;

  const HealthRepositoryImpl(this._datasource);

  @override
  Future<FichaSalud> getFichaSalud(String personaId) =>
      _datasource.getFichaSalud(personaId);

  @override
  Future<FichaSalud> guardarFichaSalud(FichaSalud ficha) =>
      _datasource.guardarFichaSalud(ficha);

  @override
  Future<List<HabitoDeVida>> getHabitosByPersona(String personaId) =>
      _datasource.getHabitosByPersona(personaId);

  @override
  Future<HabitoDeVida> crearHabito(HabitoDeVida habito) =>
      _datasource.crearHabito(habito);

  @override
  Future<HabitoDeVida> actualizarHabito(HabitoDeVida habito) =>
      _datasource.actualizarHabito(habito);

  @override
  Future<void> eliminarHabito(String habitoId) =>
      _datasource.eliminarHabito(habitoId);

  @override
  Future<List<RecomendacionMedica>> getRecomendacionesByPersona(
    String personaId,
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
  Future<void> eliminarRecomendacion(String recomendacionId) =>
      _datasource.eliminarRecomendacion(recomendacionId);

  @override
  Future<List<EventoDeSalud>> getEventosSaludByPersona(String personaId) =>
      _datasource.getEventosSaludByPersona(personaId);

  @override
  Future<EventoDeSalud> crearEventoSalud(EventoDeSalud evento) =>
      _datasource.crearEventoSalud(evento);

  @override
  Future<EventoDeSalud> actualizarEventoSalud(EventoDeSalud evento) =>
      _datasource.actualizarEventoSalud(evento);

  @override
  Future<void> eliminarEventoSalud(String eventoId) =>
      _datasource.eliminarEventoSalud(eventoId);

  @override
  Future<List<NotaEvento>> getNotasByEvento(String eventoId) =>
      _datasource.getNotasByEvento(eventoId);

  @override
  Future<NotaEvento> crearNota(NotaEvento nota) => _datasource.crearNota(nota);

  @override
  Future<List<EstadoDeAnimo>> getEstadosAnimoByPersona(String personaId) =>
      _datasource.getEstadosAnimoByPersona(personaId);

  @override
  Future<EstadoDeAnimo> crearEstadoAnimo(EstadoDeAnimo estadoAnimo) =>
      _datasource.crearEstadoAnimo(estadoAnimo);

  @override
  Future<EstadoDeAnimo> actualizarEstadoAnimo(EstadoDeAnimo estadoAnimo) =>
      _datasource.actualizarEstadoAnimo(estadoAnimo);

  @override
  Future<void> eliminarEstadoAnimo(String estadoAnimoId) =>
      _datasource.eliminarEstadoAnimo(estadoAnimoId);
}
