import 'package:care_well_app/domain/entities/entities.dart';

abstract class AlertaBienestarRepository {
  Future<List<AlertaBienestar>> getAlertasBienestar(Persona persona);
}
