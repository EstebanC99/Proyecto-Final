class EmailNoVerificadoException implements Exception {
  const EmailNoVerificadoException([
    this.mensaje = 'Tu email aún no fue verificado.',
  ]);

  final String mensaje;

  @override
  String toString() => mensaje;
}
