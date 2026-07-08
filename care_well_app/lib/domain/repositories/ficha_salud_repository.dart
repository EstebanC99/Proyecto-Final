import 'package:care_well_app/domain/entities/entities.dart';

abstract class FichaSaludRepository {
  Future<FichaSalud?> getFichaSalud(Persona persona);

  Future<void> guardarFichaSalud(FichaSalud ficha);
}
