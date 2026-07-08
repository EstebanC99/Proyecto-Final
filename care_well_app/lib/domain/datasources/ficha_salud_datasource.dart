import 'package:care_well_app/domain/entities/entities.dart';

abstract class FichaSaludDatasource {
  Future<FichaSalud?> getFichaSalud(Persona persona);

  Future<void> guardarFichaSalud(FichaSalud ficha);
}
