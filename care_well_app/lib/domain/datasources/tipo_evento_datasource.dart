import 'package:care_well_app/domain/entities/entities.dart';

abstract class TipoEventoDatasource {
  Future<List<TipoEvento>> obtenerTiposEvento();
}
