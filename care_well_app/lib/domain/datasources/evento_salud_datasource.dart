import '../entities/entities.dart';

/// Interfaz de datasource para los eventos de salud y sus notas (US-30/32/33).
///
/// Se mantiene separada de [HealthDatasource] (ficha, hábitos, recomendaciones
/// y estados de ánimo) siguiendo el patrón de `AsignacionCuidadoDatasource`:
/// esta cara del módulo salud tiene su propia implementación contra la API.
abstract class EventoSaludDatasource {
  /// Retorna los eventos de salud de la persona dentro del rango
  /// [desde, hasta] (con las notas embebidas).
  Future<List<EventoDeSalud>> getEventosSaludDelMes({
    required int personaId,
    required DateTime desde,
    required DateTime hasta,
  });

  /// Crea un evento de salud.
  Future<void> crearEventoSalud({
    required int personaId,
    required int tipoId,
    required DateTime fechaHora,
    required String descripcion,
  });

  /// Elimina el evento de salud con [eventoId].
  Future<void> eliminarEventoSalud(int eventoId);

  /// Agrega una nota al evento de salud [eventoSaludId].
  Future<void> agregarNota({
    required int eventoSaludId,
    required String contenido,
  });

  /// Modifica el contenido de la nota [notaId] del evento [eventoSaludId].
  Future<void> modificarNota({
    required int eventoSaludId,
    required int notaId,
    required String contenido,
  });

  /// Elimina la nota [notaId] del evento [eventoSaludId].
  Future<void> eliminarNota({required int eventoSaludId, required int notaId});
}
