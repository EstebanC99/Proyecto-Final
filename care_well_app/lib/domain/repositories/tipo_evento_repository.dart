import 'package:care_well_app/domain/entities/agenda/tipo_evento.dart';

abstract class TipoEventoRepository {
  /// Retorna el catálogo de tipos de evento.
  Future<List<TipoEvento>> obtenerTiposEvento();
}
