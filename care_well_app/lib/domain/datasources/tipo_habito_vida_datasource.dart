import 'package:care_well_app/domain/entities/entities.dart';

abstract class TipoHabitoVidaDatasource {
  Future<List<TipoHabitoVida>> obtenerTiposHabitosVida();
}
