import 'package:care_well_app/domain/entities/entities.dart';

abstract class SummaryRepository {
  /// Obtiene el resumen inteligente de la persona indicada para el día de hoy.
  ///
  /// Ver [SummaryDatasource.obtenerResumen] para el detalle de los parámetros.
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  });
}
