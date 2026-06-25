class SinConexionException implements Exception {
  const SinConexionException();

  @override
  String toString() => 'Sin conexión. Verificá tu red e intentá de nuevo.';
}
