import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

/// Convierte entre [EventoSaludModel] y [EventoSalud].
class EventoBaseMapper {
  EventoBaseMapper._();

  static EventoBase fromModel(EventoBaseModel model) {
    return EventoBase(
      id: model.id,
      descripcion: model.descripcion,
      categoriaEvento: model.categoriaEvento,
      fechaHora: DateTime.parse(model.fechaHora),
    );
  }
}
