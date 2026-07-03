import 'package:care_well_app/domain/entities/agenda/tipo_evento.dart';
import 'package:care_well_app/infrastructure/models/shared/tipo_evento_model.dart';

class TipoEventoMapper {
  TipoEventoMapper._();

  static TipoEvento fromModel(TipoEventoModel model) => TipoEvento(
    id: model.id,
    descripcion: model.descripcion,
    agendable: model.agendable,
  );
}
