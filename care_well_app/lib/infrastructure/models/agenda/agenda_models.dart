import 'package:care_well_app/infrastructure/models/shared/tipo_evento_model.dart';

class OcurrenciaEventoAgendaModel {
  final int eventoAgendaId;
  final int personaId;
  final String titulo;
  final String? descripcion;
  final TipoEventoModel tipo;
  final String fechaHoraInicio;
  final String fechaHoraFin;
  final bool esRecurrente;
  final bool generarEventoSalud;
  final int? minutosAnticipacionRecordatorio;

  const OcurrenciaEventoAgendaModel({
    required this.eventoAgendaId,
    required this.personaId,
    required this.titulo,
    this.descripcion,
    required this.tipo,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.esRecurrente,
    required this.generarEventoSalud,
    this.minutosAnticipacionRecordatorio,
  });

  factory OcurrenciaEventoAgendaModel.fromJson(Map<String, dynamic> json) =>
      OcurrenciaEventoAgendaModel(
        eventoAgendaId: json['eventoAgendaID'] as int,
        personaId: json['personaID'] as int,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String?,
        tipo: TipoEventoModel.fromJson(json['tipo'] as Map<String, dynamic>),
        fechaHoraInicio: json['fechaHoraInicio'] as String,
        fechaHoraFin: json['fechaHoraFin'] as String,
        esRecurrente: json['esRecurrente'] as bool,
        generarEventoSalud: json['generarEventoSalud'] as bool,
        minutosAnticipacionRecordatorio:
            json['minutosAnticipacionRecordatorio'] as int?,
      );
}
