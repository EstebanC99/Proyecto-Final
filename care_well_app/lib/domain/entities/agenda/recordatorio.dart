import '../base_entity.dart';
import 'evento_agenda.dart';

/// Recordatorio asociado a un [EventoAgenda].
///
/// Define cuándo debe dispararse la notificación local y si ya fue enviada.
class Recordatorio extends BaseEntity {
  /// Evento de agenda al que pertenece este recordatorio.
  final EventoAgenda eventoAgenda;

  final DateTime fechaHoraEnvio;

  /// `true` si la notificación ya fue despachada.
  final bool enviado;

  const Recordatorio({
    required super.id,
    required this.eventoAgenda,
    required this.fechaHoraEnvio,
    this.enviado = false,
  });

  @override
  Recordatorio copyWith({
    int? id,
    EventoAgenda? eventoAgenda,
    DateTime? fechaHoraEnvio,
    bool? enviado,
  }) {
    return Recordatorio(
      id: id ?? this.id,
      eventoAgenda: eventoAgenda ?? this.eventoAgenda,
      fechaHoraEnvio: fechaHoraEnvio ?? this.fechaHoraEnvio,
      enviado: enviado ?? this.enviado,
    );
  }
}
