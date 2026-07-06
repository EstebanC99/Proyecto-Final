import 'package:care_well_app/domain/entities/entities.dart';

abstract class SettingsRepository {
  Future<Configuracion> getConfiguracion(int usuarioId);

  Future<Configuracion> guardarConfiguracion(Configuracion configuracion);

  Future<List<AceptacionTerminos>> getAceptaciones(int usuarioId);

  Future<AceptacionTerminos> aceptarTerminos({
    required int usuarioId,
    required String version,
  });
}
