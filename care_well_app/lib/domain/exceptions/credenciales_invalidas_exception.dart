class CredencialesInvalidasException implements Exception {
  const CredencialesInvalidasException([
    this.mensaje = 'Credenciales inválidas.',
  ]);

  final String mensaje;

  @override
  String toString() => mensaje;
}
