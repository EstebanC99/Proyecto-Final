import 'package:care_well_app/domain/entities/entities.dart';

abstract class TipoHabitoVidaRepository {
  Future<List<TipoHabitoVida>> obtenerTiposHabitosVida();
}
