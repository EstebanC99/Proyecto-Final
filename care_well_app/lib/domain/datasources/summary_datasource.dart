import 'package:care_well_app/domain/entities/entities.dart';

abstract class SummaryDatasource {
  /// Obtiene el resumen inteligente de la persona indicada para el día de hoy.
  ///
  /// El rango temporal y el "ahora" los resuelve el backend a partir del id de
  /// persona; no se envían fechas.
  ///
  /// El backend guarda un resumen por persona cuidada y lo reutiliza mientras
  /// sea del mismo día calendario y tenga menos de 3 horas; en ese caso
  /// devuelve el momento de generación original, no el de la consulta.
  /// [forzarActualizacion] pide una regeneración real contra el modelo de IA,
  /// salvo que el resumen vigente tenga menos de un minuto (piso del backend
  /// contra el doble tap: en ese caso devuelve el vigente, sin error).
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  });
}
