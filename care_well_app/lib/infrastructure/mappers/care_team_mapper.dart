import '../../domain/entities/entities.dart';
import '../models/models.dart';

/// Convierte entre [PermisoModel] y [Permiso].
class PermisoMapper {
  PermisoMapper._();

  static const _codigoMap = {
    'verFichaSalud': CodigoPermiso.verFichaSalud,
    'editarFichaSalud': CodigoPermiso.editarFichaSalud,
    'gestionarAgenda': CodigoPermiso.gestionarAgenda,
    'registrarEventosSalud': CodigoPermiso.registrarEventosSalud,
    'registrarHabitos': CodigoPermiso.registrarHabitos,
    'activarEmergencia': CodigoPermiso.activarEmergencia,
    'administrarEquipo': CodigoPermiso.administrarEquipo,
  };

  static const _codigoReverseMap = {
    CodigoPermiso.verFichaSalud: 'verFichaSalud',
    CodigoPermiso.editarFichaSalud: 'editarFichaSalud',
    CodigoPermiso.gestionarAgenda: 'gestionarAgenda',
    CodigoPermiso.registrarEventosSalud: 'registrarEventosSalud',
    CodigoPermiso.registrarHabitos: 'registrarHabitos',
    CodigoPermiso.activarEmergencia: 'activarEmergencia',
    CodigoPermiso.administrarEquipo: 'administrarEquipo',
  };

  static Permiso fromModel(PermisoModel model) {
    return Permiso(
      id: model.id,
      codigo: _codigoMap[model.codigo] ?? CodigoPermiso.verFichaSalud,
      descripcion: model.descripcion,
    );
  }

  static PermisoModel toModel(Permiso entity) {
    return PermisoModel(
      id: entity.id,
      codigo: _codigoReverseMap[entity.codigo] ?? 'verFichaSalud',
      descripcion: entity.descripcion,
    );
  }
}

/// Convierte entre [RolModel] y [Rol].
class RolMapper {
  RolMapper._();

  static const _nombreMap = {
    'responsable': RolCuidado.responsable,
    'cuidador': RolCuidado.cuidador,
  };

  static const _nombreReverseMap = {
    RolCuidado.responsable: 'responsable',
    RolCuidado.cuidador: 'cuidador',
  };

  static Rol fromModel(RolModel model) {
    return Rol(
      id: model.id,
      nombre: _nombreMap[model.nombre] ?? RolCuidado.cuidador,
    );
  }

  static RolModel toModel(Rol entity) {
    return RolModel(
      id: entity.id,
      nombre: _nombreReverseMap[entity.nombre] ?? 'cuidador',
    );
  }
}

/// Convierte entre [AsignacionCuidadoModel] y [AsignacionCuidado].
class AsignacionCuidadoMapper {
  AsignacionCuidadoMapper._();

  static const _estadoMap = {
    'activa': EstadoAsignacion.activa,
    'inactiva': EstadoAsignacion.inactiva,
    'pendiente': EstadoAsignacion.pendiente,
  };

  static const _estadoReverseMap = {
    EstadoAsignacion.activa: 'activa',
    EstadoAsignacion.inactiva: 'inactiva',
    EstadoAsignacion.pendiente: 'pendiente',
  };

  /// Requiere [personaCuidada], [personaColaborador] y [rol] ya construidos.
  static AsignacionCuidado fromModel(
    AsignacionCuidadoModel model, {
    required Persona personaCuidada,
    required Persona personaColaborador,
    required Rol rol,
  }) {
    return AsignacionCuidado(
      id: model.id,
      personaCuidada: personaCuidada,
      personaColaborador: personaColaborador,
      rol: rol,
      estado: _estadoMap[model.estado] ?? EstadoAsignacion.activa,
      fechaAlta: DateTime.parse(model.fechaAlta),
      permisos: model.permisos.map(PermisoMapper.fromModel).toList(),
    );
  }

  static AsignacionCuidadoModel toModel(AsignacionCuidado entity) {
    return AsignacionCuidadoModel(
      id: entity.id,
      personaCuidadaId: entity.personaCuidada.id,
      personaColaboradorId: entity.personaColaborador.id,
      rolId: entity.rol.id,
      estado: _estadoReverseMap[entity.estado] ?? 'activa',
      fechaAlta: entity.fechaAlta.toIso8601String(),
      permisos: entity.permisos.map(PermisoMapper.toModel).toList(),
    );
  }
}
