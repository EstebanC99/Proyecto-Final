import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class EstadoAnimoRepositoryImpl implements EstadoAnimoRepository {
  final EstadoAnimoDatasource _datasource;

  const EstadoAnimoRepositoryImpl(this._datasource);

  @override
  Future<PersonaEstadoAnimo?> obtenerAnimoHoy(Persona persona) =>
      _datasource.obtenerAnimoHoy(persona);

  @override
  Future<List<PersonaEstadoAnimo>> obtenerPorFechas({
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
