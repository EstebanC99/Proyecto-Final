import 'package:care_well_app/domain/entities/entities.dart';

abstract class SummaryDatasource {
  /// Obtiene el resumen inteligente de la persona indicada para el día de hoy.
  ///
  /// El rango temporal y el "ahora" los resuelve el backend a partir del id de
  /// persona; no se envían fechas. [forzarActualizacion] permite pedir una
  /// regeneración ignorando cualquier caché del lado del servidor (en el MVP no
  /// hay caché, por lo que cada llamada genera de nuevo).
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  });
}
