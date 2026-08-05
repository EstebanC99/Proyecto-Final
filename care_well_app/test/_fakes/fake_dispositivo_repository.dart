import 'dart:async';

import 'package:care_well_app/domain/repositories/repositories.dart';

/// Fake del repositorio de dispositivos que registra las llamadas recibidas.
class FakeDispositivoRepository implements DispositivoRepository {
  FakeDispositivoRepository({this.log});

  /// Log compartido para verificar el ORDEN relativo a otras operaciones.
  final List<String>? log;

  final List<({String token, int plataforma})> registrados = [];
  final List<String> eliminados = [];

  /// Si es `true`, `eliminar` falla (simula caída de red en el logout).
  bool fallarAlEliminar = false;

  /// Si se setea, `registrar` queda pendiente hasta completarlo. Sirve para
  /// simular un alta que todavía no llegó al backend.
  Completer<void>? registrarPendiente;

  @override
  Future<void> registrar({
    required String token,
    required int plataforma,
  }) async {
    // El log se escribe DESPUÉS de la espera a propósito: representa el momento
    // en que el backend procesa el alta, que es el orden que importa frente a
    // la baja. Loguear antes haría pasar el test de la carrera sin arreglarla.
    if (registrarPendiente != null) await registrarPendiente!.future;

    registrados.add((token: token, plataforma: plataforma));
    log?.add('registrar');
  }

  @override
  Future<void> eliminar({required String token}) async {
    log?.add('eliminar');
    if (fallarAlEliminar) throw Exception('sin red');
    eliminados.add(token);
  }
}
