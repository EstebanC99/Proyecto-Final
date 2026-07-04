import '../entities/entities.dart';

/// Interfaz de datasource para hábitos de vida y sus realizaciones diarias.
///
/// Separada de [HealthDatasource] (ficha, recomendaciones, estados de ánimo)
/// siguiendo el patrón de [EventoSaludDatasource]: esta cara del módulo salud
/// tiene su propia implementación contra la API.
abstract class HabitoVidaDatasource {
  /// Retorna los hábitos activos de la persona con [personaId].
  ///
  /// La realización del día actual viene embebida en cada [HabitoDeVida]
  /// si existe; de lo contrario el campo es `null`.
  Future<List<HabitoDeVida>> getHabitosByPersona(int personaId);

  /// Crea un hábito de vida para la persona [personaId].
  Future<void> crearHabito({
    required int personaId,
    required int tipoId,
    required String descripcion,
  });

  /// Modifica el tipo y descripción del hábito [habitoId].
  Future<void> modificarHabito({
    required int habitoId,
    required int tipoId,
    required String descripcion,
  });

  /// Da de baja (lógica) el hábito [habitoId].
  Future<void> eliminarHabito(int habitoId);

  /// Registra que el hábito [habitoId] fue realizado hoy.
  Future<void> crearRealizacion({required int habitoId, String? comentarios});

  /// Modifica el comentario de la realización [realizacionId] del hábito [habitoId].
  Future<void> modificarRealizacion({
    required int habitoId,
    required int realizacionId,
    String? comentarios,
  });

  /// Elimina la realización [realizacionId] del hábito [habitoId].
  Future<void> eliminarRealizacion({
    required int habitoId,
    required int realizacionId,
  });
}
