import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class AlertaBienestarMapper {
  AlertaBienestarMapper._();

  static AlertaBienestar fromModel(AlertaBienestarModel model) {
    return AlertaBienestar(
      tipo: model.tipo,
      severidad: model.severidad,
      categoria: model.categoria,
      mensaje: model.mensaje,
      fechaDeteccion: model.fechaDeteccion,
      habitoVidaId: model.habitoVidaId,
    );
  }
}
