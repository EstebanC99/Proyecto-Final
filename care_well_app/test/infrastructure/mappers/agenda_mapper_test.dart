import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TipoEventoMapper', () {
    test('fromModel mapea id, descripcion y agendable', () {
      final model = TipoEventoModel.fromJson(const {
        'id': 1,
        'descripcion': 'Cita Médica',
        'agendable': true,
      });

      final tipo = TipoEventoMapper.fromModel(model);

      expect(tipo.id, 1);
      expect(tipo.descripcion, 'Cita Médica');
      expect(tipo.agendable, isTrue);
    });

    test('agendable ausente en el JSON se resuelve como true por defecto', () {
      final model = TipoEventoModel.fromJson(const {
        'id': 4,
        'descripcion': 'Otro',
      });

      final tipo = TipoEventoMapper.fromModel(model);

      expect(tipo.agendable, isTrue);
    });

    test('agendable false se preserva', () {
      final model = TipoEventoModel.fromJson(const {
        'id': 99,
        'descripcion': 'No agendable',
        'agendable': false,
      });

      final tipo = TipoEventoMapper.fromModel(model);

      expect(tipo.agendable, isFalse);
    });
  });

  group('OcurrenciaEventoAgendaMapper', () {
    test('fromModel mapea un JSON realista del backend', () {
      final model = OcurrenciaEventoAgendaModel.fromJson(const {
        'eventoAgendaID': 501,
        'personaID': 12,
        'titulo': 'Control cardiológico',
        'descripcion': 'Llevar estudios previos',
        'tipo': {'id': 1, 'descripcion': 'Cita Médica', 'agendable': true},
        'fechaHoraInicio': '2026-07-15T09:30:00.000',
        'fechaHoraFin': '2026-07-15T10:00:00.000',
        'esRecurrente': false,
        'generarEventoSalud': true,
        'minutosAnticipacionRecordatorio': 30,
      });

      final ocu = OcurrenciaEventoAgendaMapper.fromModel(model);

      // eventoAgendaID / personaID (casing del backend) → eventoAgendaId / personaId.
      expect(ocu.eventoAgendaId, 501);
      expect(ocu.personaId, 12);
      // id se deriva del id del evento base.
      expect(ocu.id, 501);
      expect(ocu.titulo, 'Control cardiológico');
      expect(ocu.descripcion, 'Llevar estudios previos');

      // Tipo anidado.
      expect(ocu.tipo.id, 1);
      expect(ocu.tipo.descripcion, 'Cita Médica');
      expect(ocu.tipo.agendable, isTrue);

      // Fechas ISO 8601 → DateTime.
      expect(ocu.fechaHoraInicio, DateTime(2026, 7, 15, 9, 30));
      expect(ocu.fechaHoraFin, DateTime(2026, 7, 15, 10, 0));

      expect(ocu.esRecurrente, isFalse);
      expect(ocu.generarEventoSalud, isTrue);
      expect(ocu.minutosAnticipacionRecordatorio, 30);
    });

    test('campos opcionales nulos se preservan como null', () {
      final model = OcurrenciaEventoAgendaModel.fromJson(const {
        'eventoAgendaID': 700,
        'personaID': 3,
        'titulo': 'Recordatorio simple',
        'descripcion': null,
        'tipo': {'id': 4, 'descripcion': 'Otro', 'agendable': true},
        'fechaHoraInicio': '2026-08-01T08:00:00.000',
        'fechaHoraFin': '2026-08-01T08:30:00.000',
        'esRecurrente': true,
        'generarEventoSalud': false,
        'minutosAnticipacionRecordatorio': null,
      });

      final ocu = OcurrenciaEventoAgendaMapper.fromModel(model);

      expect(ocu.descripcion, isNull);
      expect(ocu.minutosAnticipacionRecordatorio, isNull);
      expect(ocu.esRecurrente, isTrue);
      expect(ocu.generarEventoSalud, isFalse);
    });
  });
}
