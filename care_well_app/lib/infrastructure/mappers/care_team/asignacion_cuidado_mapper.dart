import 'package:care_well_app/domain/entities/care_team/asignacion_cuidado.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/care_team/asignacion_cuidado_model.dart';

class AsignacionCuidadoMapper {
  static AsignacionCuidado fromModel(AsignacionCuidadoModel model) {
    return AsignacionCuidado(
      id: model.id,
      personaCuidada: PersonaMapper.fromModel(model.persona),
      colaborador: PersonaMapper.fromModel(model.colaborador),
      rol: RolCuidadoMapper.fromModel(model.rol),
      estado: EstadoAsignacionCuidadoMapper.fromModel(model.estado),
      fechaAlta: DateTime.parse(model.fechaAlta),
      fechaEliminacion: model.fechaEliminacion == null
          ? null
          : DateTime.parse(model.fechaEliminacion!),
      permisos: model.permisos
          .map((p) => PermisoCuidadoMapper.fromModel(p))
          .toList(),
    );
  }
}
