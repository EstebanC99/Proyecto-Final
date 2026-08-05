/// Contrato de acceso a datos de los dispositivos del usuario.
///
/// Un dispositivo representa una INSTALACIÓN de la app, identificada por su
/// token de mensajería push. El backend lo usa para saber a dónde enviar los
/// avisos del equipo de cuidado.
abstract class DispositivoDatasource {
  /// Registra (o reasigna al usuario en sesión) el dispositivo del token dado.
  ///
  /// [plataforma] es un valor de `PlataformasDispositivoConst`.
  Future<void> registrar({required String token, required int plataforma});

  /// Da de baja el dispositivo del token dado.
  ///
  /// Requiere sesión activa: hay que invocarlo ANTES de limpiar las
  /// credenciales al cerrar sesión.
  Future<void> eliminar({required String token});
}
