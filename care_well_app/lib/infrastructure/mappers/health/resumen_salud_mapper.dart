import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/models/models.dart';

class ResumenSaludMapper {
  ResumenSaludMapper._();

  static ResumenSalud fromModel(ResumenSaludModel model) {
    return ResumenSalud(
      grupoSanguineo: model.grupoSanguineo,
      cantidadAlergias: model.cantidadAlergias,
      cantidadAntecedentes: model.cantidadAntecedentes,
      cantidadEnfermedades: model.cantidadEnfermedades,
      cantidadHabitosCompletados: model.cantidadHabitosCompletados,
      cantidadHabitos: model.cantidadHabitos,
      estadoAnimoId: model.estadoAnimoId,
      ultimoEventoSalud: model.ultimoEventoSalud,
      // Sin evento el backend manda 0 días, que como dato es ruido: la entidad
      // lo expresa como ausencia para que la UI no muestre "hoy" por error.
      diasDesdeUltimoEvento: model.ultimoEventoSalud == null
          ? null
          : model.cantidadDias,
    );
  }
}
