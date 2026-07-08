import 'package:care_well_app/domain/entities/entities.dart';

abstract class AlertaBienestarDatasource {
  Future<List<AlertaBienestar>> getAlertasBienestar(Persona persona);
}
