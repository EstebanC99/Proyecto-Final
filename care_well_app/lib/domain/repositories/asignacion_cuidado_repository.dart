import '../entities/entities.dart';

/// Contrato de repositorio para las operaciones de [AsignacionCuidado]
/// que involucran al usuario logueado como colaborador.
abstract class AsignacionCuidadoRepository {
  /// Crea una persona a cargo y la vincula al usuario logueado como Responsable
  /// en una sola operación atómica.
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
    List<int> permisosCuidadoIds = const [],
  });

  /// Retorna todas las [AsignacionCuidado] donde el usuario logueado
  /// figura como colaborador (responsable o cuidador).
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado();
}
