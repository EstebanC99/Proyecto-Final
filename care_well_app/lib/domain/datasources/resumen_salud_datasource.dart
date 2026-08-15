import 'package:care_well_app/domain/entities/entities.dart';

abstract class ResumenSaludDatasource {
  Future<ResumenSalud> getResumenSalud(Persona persona);
}
