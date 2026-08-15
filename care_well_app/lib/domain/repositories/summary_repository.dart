import 'package:care_well_app/domain/entities/entities.dart';

abstract class SummaryRepository {
  /// Obtiene el resumen inteligente de la persona indicada para el día de hoy.
  ///
  /// El backend cachea el resumen por persona (mismo día, menos de 3 horas) y
  /// sólo regenera cuando se pide con [forzarActualizacion]. Ver
  /// [SummaryDatasource.obtenerResumen] para el detalle de los parámetros.
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  });
}
