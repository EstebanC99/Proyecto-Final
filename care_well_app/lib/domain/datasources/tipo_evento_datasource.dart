import 'package:care_well_app/domain/entities/entities.dart';

abstract class TipoEventoDatasource {
  /// Retorna el catálogo de tipos de evento.
  Future<List<TipoEvento>> obtenerTiposEvento();
}