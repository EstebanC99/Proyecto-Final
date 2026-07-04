class RecursoNoEncontradoException implements Exception {
  const RecursoNoEncontradoException([
    this.mensaje = 'El recurso solicitado no fue encontrado.',
  ]);

  final String mensaje;

  @override
  String toString() => mensaje;
}
