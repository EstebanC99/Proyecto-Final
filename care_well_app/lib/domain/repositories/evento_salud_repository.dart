import '../entities/entities.dart';

/// Contrato de repositorio para los eventos de salud y sus notas.
abstract class EventoSaludRepository {
  /// Retorna los eventos de salud de la persona dentro del rango [desde, hasta].
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
