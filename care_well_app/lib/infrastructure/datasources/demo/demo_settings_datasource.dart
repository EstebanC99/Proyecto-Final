import '../../../domain/datasources/datasources.dart';
import '../../../domain/entities/entities.dart';
import 'demo_seed.dart';

/// Implementación demo (en memoria) de [SettingsDatasource].
class DemoSettingsDatasource implements SettingsDatasource {
  final Map<int, Configuracion> _configuraciones = {
    DemoSeed.usuarioMariaId: DemoSeed.configuracionMaria,
  };

  final List<AceptacionTerminos> _aceptaciones = List.of(
    DemoSeed.aceptacionesMaria,
  );

  /// Mapa de usuarioId → Usuario para resolver referencias en demo.
  final Map<int, Usuario> _usuariosById = {
    DemoSeed.usuarioMariaId: DemoSeed.usuarioMaria,
  };

  int _nextId = 10000;

  @override
  Future<Configuracion> getConfiguracion(int usuarioId) async {
    await Future.delayed(Duration.zero);
    if (_configuraciones.containsKey(usuarioId)) {
      return _configuraciones[usuarioId]!;
    }
    final usuario = _usuariosById[usuarioId];
    if (usuario == null) throw Exception('Usuario no encontrado: $usuarioId');
    return Configuracion(id: _nextId++, usuario: usuario);
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
  Future<List<AceptacionTerminos>> getAceptaciones(int usuarioId) async {
    await Future.delayed(Duration.zero);
    return _aceptaciones.where((a) => a.usuario.id == usuarioId).toList();
  }

  @override
  Future<AceptacionTerminos> aceptarTerminos({
    required int usuarioId,
    required String version,
  }) async {
    await Future.delayed(Duration.zero);
    final usuario = _usuariosById[usuarioId];
    if (usuario == null) throw Exception('Usuario no encontrado: $usuarioId');
    final aceptacion = AceptacionTerminos(
      id: _nextId++,
      usuario: usuario,
      version: version,
      fechaAceptacion: DateTime.now(),
    );
    _aceptaciones.add(aceptacion);
    return aceptacion;
  }
}
