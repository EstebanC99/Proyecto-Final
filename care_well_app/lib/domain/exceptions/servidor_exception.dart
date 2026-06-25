class ServidorException implements Exception {
  const ServidorException();

  @override
  String toString() => 'Ocurrió un error inesperado. Intentá de nuevo más tarde.';
}
