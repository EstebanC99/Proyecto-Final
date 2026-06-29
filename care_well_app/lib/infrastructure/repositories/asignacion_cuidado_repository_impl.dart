import 'package:care_well_app/domain/datasources/datasources.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';

class AsignacionCuidadoRepositoryImpl implements AsignacionCuidadoRepository {
  final AsignacionCuidadoDatasource _datasource;

  const AsignacionCuidadoRepositoryImpl(this._datasource);

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesUsuarioLogueado() =>
      _datasource.obtenerAsignacionesUsuarioLogueado();

  @override
  Future<List<AsignacionCuidado>> obtenerAsignacionesPorPersona(
    int personaCuidadaId,
  ) => _datasource.obtenerAsignacionesPorPersona(personaCuidadaId);

  @override
  Future<void> crearPersonaCargo({
    required String nombre,
    required String apellido,
    required String documento,
    required DateTime fechaNacimiento,
    String? email,
    String? telefono,
  }) => _datasource.crearPersonaCargo(
    nombre: nombre,
    apellido: apellido,
    documento: documento,
    fechaNacimiento: fechaNacimiento,
    email: email,
    telefono: telefono,
  );

  @override
  Future<Persona> modificarPersonaCargo(int asignacionId, Persona persona) =>
      _datasource.modificarPersonaCargo(asignacionId, persona);

  @override
  Future<void> asignarPersonaEquipoCuidado({
    required int personaCuidadaId,
    required String colaboradorEmail,
    required int rolCuidadoId,
    required List<int> permisosCuidadoIds,
  }) => _datasource.asignarPersonaEquipoCuidado(
    personaCuidadaId: personaCuidadaId,
    colaboradorEmail: colaboradorEmail,
    rolCuidadoId: rolCuidadoId,
    permisosCuidadoIds: permisosCuidadoIds,
  );

  @override
  Future<void> modificarPermisosAsignacion({
    required int asignacionId,
    required List<PermisoCuidado> permisosSeleccionados,
  }) => _datasource.modificarPermisosAsignacion(
    asignacionId: asignacionId,
    permisosSeleccionados: permisosSeleccionados,
  );

  @override
  Future<void> eliminarAsignacion(int asignacionId) =>
      _datasource.eliminarAsignacion(asignacionId);

  @override
  Future<void> activarAsignacion(int asignacionId) =>
      _datasource.activarAsignacion(asignacionId);

  @override
  Future<void> reactivarAsignacion(int asignacionId) =>
      _datasource.reactivarAsignacion(asignacionId);
}
