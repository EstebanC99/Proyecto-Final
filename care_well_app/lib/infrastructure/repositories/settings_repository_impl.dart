import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [SettingsRepository] que delega al [SettingsDatasource] inyectado.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDatasource _datasource;

  const SettingsRepositoryImpl(this._datasource);

  @override
  Future<Configuracion> getConfiguracion(String usuarioId) =>
      _datasource.getConfiguracion(usuarioId);

  @override
  Future<Configuracion> guardarConfiguracion(Configuracion configuracion) =>
      _datasource.guardarConfiguracion(configuracion);

  @override
  Future<List<AceptacionTerminos>> getAceptaciones(String usuarioId) =>
      _datasource.getAceptaciones(usuarioId);

  @override
  Future<AceptacionTerminos> aceptarTerminos({
    required String usuarioId,
    required String version,
  }) => _datasource.aceptarTerminos(usuarioId: usuarioId, version: version);
}
