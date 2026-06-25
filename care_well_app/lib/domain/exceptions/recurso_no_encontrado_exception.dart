class RecursoNoEncontradoException implements Exception {
  const RecursoNoEncontradoException();

  @override
  String toString() => 'El recurso solicitado no fue encontrado.';
}
