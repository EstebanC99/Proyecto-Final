import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDatasource _datasource;

  const SettingsRepositoryImpl(this._datasource);

  @override
  Future<Configuracion> getConfiguracion(int usuarioId) =>
      _datasource.getConfiguracion(usuarioId);

  @override
  Future<Configuracion> guardarConfiguracion(Configuracion configuracion) =>
      _datasource.guardarConfiguracion(configuracion);

  @override
  Future<List<AceptacionTerminos>> getAceptaciones(int usuarioId) =>
      _datasource.getAceptaciones(usuarioId);

  @override
  Future<AceptacionTerminos> aceptarTerminos({
    required int usuarioId,
    required String version,
  }) => _datasource.aceptarTerminos(usuarioId: usuarioId, version: version);
}
