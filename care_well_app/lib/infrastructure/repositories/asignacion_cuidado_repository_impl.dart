import '../../domain/datasources/datasources.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';

/// Implementación de [AsignacionCuidadoRepository] que delega al
/// [AsignacionCuidadoDatasource] inyectado.
class AsignacionCuidadoRepositoryImpl implements AsignacionCuidadoRepository {
  final AsignacionCuidadoDatasource _datasource;

  const AsignacionCuidadoRepositoryImpl(this._datasource);

  @override
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
    List<int> permisosCuidadoIds = const [],
  }) => _datasource.crearPersonaCargo(
    nombre: nombre,
    apellido: apellido,
    documento: documento,
    fechaNacimiento: fechaNacimiento,
    email: email,
    telefono: telefono,
    permisosCuidadoIds: permisosCuidadoIds,
  );

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() =>
      _datasource.obtenerAsignacionesUsuarioLogueado();
}
