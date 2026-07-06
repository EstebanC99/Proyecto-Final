import 'package:care_well_app/domain/entities/entities.dart';

abstract class EstadoAnimoDatasource {
  Future<PersonaEstadoAnimo?> obtenerAnimoHoy(Persona persona);

  Future<List<PersonaEstadoAnimo>> obtenerPorFechas({
    required Persona persona,
    required DateTime desde,
    required DateTime hasta,
  });

  Future<void> registrar({
    required int personaId,
    required int estadoAnimoId,
    String? observaciones,
  });
}
