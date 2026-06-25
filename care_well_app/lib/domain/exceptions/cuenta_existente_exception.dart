class CuentaExistenteException implements Exception {
  const CuentaExistenteException();

  @override
  String toString() => 'Ya existe una cuenta con ese email.';
}
