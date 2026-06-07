import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [SettingsDatasource].
class DemoSettingsDatasource implements SettingsDatasource {
  final Map<String, Configuracion> _configuraciones = {
    DemoSeed.usuarioMariaId: DemoSeed.configuracionMaria,
  };

  final List<AceptacionTerminos> _aceptaciones = List.of(
    DemoSeed.aceptacionesMaria,
  );

  /// Mapa de usuarioId → Usuario para resolver referencias en demo.
  final Map<String, Usuario> _usuariosById = {
    DemoSeed.usuarioMariaId: DemoSeed.usuarioMaria,
  };

  @override
  Future<Configuracion> getConfiguracion(String usuarioId) async {
    await Future.delayed(Duration.zero);
    if (_configuraciones.containsKey(usuarioId)) {
      return _configuraciones[usuarioId]!;
    }
    final usuario = _usuariosById[usuarioId];
    if (usuario == null) throw Exception('Usuario no encontrado: $usuarioId');
    return Configuracion(
      id: 'cfg_${DateTime.now().millisecondsSinceEpoch}',
      usuario: usuario,
    );
  }

  @override
  Future<Configuracion> guardarConfiguracion(
    Configuracion configuracion,
  ) async {
    await Future.delayed(Duration.zero);
    _configuraciones[configuracion.usuario.id] = configuracion;
    return configuracion;
  }

  @override
  Future<List<AceptacionTerminos>> getAceptaciones(String usuarioId) async {
    await Future.delayed(Duration.zero);
    return _aceptaciones.where((a) => a.usuario.id == usuarioId).toList();
  }

  @override
  Future<AceptacionTerminos> aceptarTerminos({
    required String usuarioId,
    required String version,
  }) async {
    await Future.delayed(Duration.zero);
    final usuario = _usuariosById[usuarioId];
    if (usuario == null) throw Exception('Usuario no encontrado: $usuarioId');
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final aceptacion = AceptacionTerminos(
      id: 'acc_$ts',
      usuario: usuario,
      version: version,
      fechaAceptacion: DateTime.now(),
    );
    _aceptaciones.add(aceptacion);
    return aceptacion;
  }
}
