import 'package:care_well_app/domain/entities/entities.dart';

abstract class HabitoVidaDatasource {
  Future<List<HabitoVida>> getHabitosByPersona(int personaId);

  Future<void> crearHabito({
    required int personaId,
    required int tipoId,
    required String descripcion,
  });

  Future<void> modificarHabito({
    required int habitoId,
    required int tipoId,
    required String descripcion,
  });

  Future<void> eliminarHabito(int habitoId);

  Future<void> crearRealizacion({required int habitoId, String? comentarios});

  Future<void> modificarRealizacion({
    required int habitoId,
    required int realizacionId,
    String? comentarios,
  });

  Future<void> eliminarRealizacion({
    required int habitoId,
    required int realizacionId,
  });
}
