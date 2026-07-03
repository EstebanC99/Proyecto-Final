import 'package:care_well_app/domain/entities/agenda/ocurrencia_evento_agenda.dart';
import 'package:care_well_app/infrastructure/mappers/shared/tipo_evento_mapper.dart';
import 'package:care_well_app/infrastructure/models/agenda/agenda_models.dart';

class OcurrenciaEventoAgendaMapper {
  OcurrenciaEventoAgendaMapper._();

  static OcurrenciaEventoAgenda fromModel(OcurrenciaEventoAgendaModel model) =>
      OcurrenciaEventoAgenda(
        id: model.eventoAgendaId,
        eventoAgendaId: model.eventoAgendaId,
        personaId: model.personaId,
        titulo: model.titulo,
        descripcion: model.descripcion,
        tipo: TipoEventoMapper.fromModel(model.tipo),
        fechaHoraInicio: DateTime.parse(model.fechaHoraInicio),
        fechaHoraFin: DateTime.parse(model.fechaHoraFin),
        esRecurrente: model.esRecurrente,
        generarEventoSalud: model.generarEventoSalud,
        minutosAnticipacionRecordatorio: model.minutosAnticipacionRecordatorio,
      );
}
