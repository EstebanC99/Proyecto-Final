/// Cifras de cabecera del perfil del usuario autenticado.
///
/// Es un *read model* de presentación: agrega datos que ya están en otros
/// providers para pintarlos como casillas en la pantalla de perfil. No es una
/// entidad de dominio.
class StatsPerfil {
  const StatsPerfil({
    required this.aCargo,
    required this.colaboro,
    required this.edad,
  });

  /// Personas distintas de las que el usuario es responsable activo.
  final int aCargo;

  /// Personas distintas en las que el usuario colabora como cuidador activo.
  final int colaboro;

  /// Edad del usuario en años cumplidos. Nulo si no hay sesión activa.
  final int? edad;
}
