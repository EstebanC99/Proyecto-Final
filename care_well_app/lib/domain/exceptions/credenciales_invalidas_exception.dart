class CredencialesInvalidasException implements Exception {
  const CredencialesInvalidasException();

  @override
  String toString() => 'Credenciales inválidas.';
}
