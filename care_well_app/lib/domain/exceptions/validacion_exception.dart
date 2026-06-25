class ValidacionException implements Exception {
  final String mensaje;

  const ValidacionException(this.mensaje);

  @override
  String toString() => mensaje;
}
