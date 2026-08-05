import '../../domain/entities/entities.dart';
import '../models/models.dart';
import 'shared/persona_mapper.dart';

/// Convierte [EmergenciaModel] en [Emergencia].
///
/// Es unidireccional: la emergencia es un registro de solo lectura para el
/// cliente (ver [EmergenciaModel]).
class EmergenciaMapper {
  EmergenciaMapper._();

  static Emergencia fromModel(EmergenciaModel model) {
    return Emergencia(
      id: model.id,
      persona: PersonaMapper.fromModel(model.persona),
      activador: PersonaMapper.fromModel(model.activador),
      fechaHora: DateTime.parse(model.fechaHora),
      descripcion: model.descripcion,
    );
  }
}
