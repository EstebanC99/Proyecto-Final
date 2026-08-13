import 'package:care_well_app/domain/entities/entities.dart';

abstract class ResumenSaludRepository {
  Future<ResumenSalud> getResumenSalud(Persona persona);
}
