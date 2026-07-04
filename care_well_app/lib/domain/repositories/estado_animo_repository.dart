import '../entities/entities.dart';

/// Contrato de repositorio para estados de ánimo de una persona.
abstract class EstadoAnimoRepository {
  /// Retorna el estado de ánimo registrado hoy para [persona], o `null` si no hay.
  Future<EstadoDeAnimo?> obtenerAnimoHoy(Persona persona);

  /// Retorna los estados de ánimo de [persona] en el rango [desde, hasta).
  Future<List<EstadoDeAnimo>> obtenerPorFechas({
    required Persona persona,
    required DateTime desde,
    required DateTime hasta,
  });

  /// Registra un estado de ánimo para la persona [personaId].
  ///
  /// La fecha/hora la fija el servidor. Pueden existir varios registros por día.
  Future<void> registrar({
    required int personaId,
    required int estadoAnimoId,
    String? observaciones,
  });
}
