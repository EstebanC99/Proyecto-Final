/// Contrato de repositorio de los dispositivos del usuario.
///
/// Ver `DispositivoDatasource` para el detalle de cada operación.
abstract class DispositivoRepository {
  /// Registra (o reasigna al usuario en sesión) el dispositivo del token dado.
  ///
  /// [plataforma] es un valor de `PlataformasDispositivoConst`.
  Future<void> registrar({required String token, required int plataforma});

  /// Da de baja el dispositivo del token dado. Requiere sesión activa.
  Future<void> eliminar({required String token});
}
