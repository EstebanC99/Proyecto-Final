/// Se lanza cuando un servicio del backend no está disponible temporalmente
/// (HTTP 503), p. ej. el servicio de validación de identidad durante el
/// registro. El error no es atribuible a los datos del usuario: puede reintentar
/// la misma operación más tarde.
class ServicioNoDisponibleException implements Exception {
  final String mensaje;

  const ServicioNoDisponibleException(this.mensaje);

  @override
  String toString() => mensaje;
}
