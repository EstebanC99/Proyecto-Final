import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class ResumenInteligenteMapper {
  ResumenInteligenteMapper._();

  static ResumenInteligente fromModel(ResumenInteligenteModel model) {
    return ResumenInteligente(
      texto: model.texto,
      tieneDatos: model.tieneDatos,
      generadoEn: model.generadoEn,
    );
  }
}
