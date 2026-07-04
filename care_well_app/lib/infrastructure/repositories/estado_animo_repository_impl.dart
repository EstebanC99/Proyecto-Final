import '../../domain/datasources/estado_animo_datasource.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/estado_animo_repository.dart';

/// Implementación de [EstadoAnimoRepository] que delega al [EstadoAnimoDatasource] inyectado.
class EstadoAnimoRepositoryImpl implements EstadoAnimoRepository {
  final EstadoAnimoDatasource _datasource;

  const EstadoAnimoRepositoryImpl(this._datasource);

  @override
  Future<EstadoDeAnimo?> obtenerAnimoHoy(Persona persona) =>
      _datasource.obtenerAnimoHoy(persona);

  @override
  Future<List<EstadoDeAnimo>> obtenerPorFechas({
    required Persona persona,
    required DateTime desde,
    required DateTime hasta,
  }) => _datasource.obtenerPorFechas(
    persona: persona,
    desde: desde,
    hasta: hasta,
  );

  @override
  Future<void> registrar({
    required int personaId,
    required int estadoAnimoId,
    String? observaciones,
  }) => _datasource.registrar(
    personaId: personaId,
    estadoAnimoId: estadoAnimoId,
    observaciones: observaciones,
  );
}
