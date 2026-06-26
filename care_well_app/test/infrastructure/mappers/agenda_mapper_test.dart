import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final persona = Persona(
    id: 2,
    nombre: 'Alicia',
    apellido: 'Rodríguez',
    documento: "123123",
    fechaNacimiento: DateTime.now(),
  );

  final usuario = Usuario(
    id: 101,
    persona: Persona(
      id: 1,
      nombre: 'María',
      apellido: 'García',
      documento: "123123",
      fechaNacimiento: DateTime.now(),
    ),
    contrasena: 'hash123',
    estado: EstadoUsuario(
      id: EstadosUsuarioConst.activo,
      descripcion: 'Activo',
    ),
  );

  final tipoCitaMedica = TipoEventoAgenda(
    id: TiposEventoAgendaConst.citaMedica,
    descripcion: 'Cita médica',
  );

  final tipoMedicacion = TipoEventoAgenda(
    id: TiposEventoAgendaConst.medicacion,
    descripcion: 'Medicación',
  );

  group('EventoAgendaMapper', () {
    final evento = EventoAgenda(
      id: 701,
      persona: persona,
      creadoPor: usuario,
      titulo: 'Consulta cardiológica',
      descripcion: 'Control anual',
      tipo: tipoCitaMedica,
      fechaHoraInicio: DateTime(2026, 6, 10, 10, 0),
      fechaHoraFin: DateTime(2026, 6, 10, 11, 0),
    );

    final model = EventoAgendaModel(
      id: 701,
      personaId: 2,
      creadoPorId: 101,
      titulo: 'Consulta cardiológica',
      descripcion: 'Control anual',
      tipo: TipoEventoAgendaModel(
        id: TiposEventoAgendaConst.citaMedica,
        descripcion: 'Cita médica',
      ),
      fechaHoraInicio: '2026-06-10T10:00:00.000',
      fechaHoraFin: '2026-06-10T11:00:00.000',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = EventoAgendaMapper.fromModel(
        EventoAgendaMapper.toModel(evento),
        persona: persona,
        creadoPor: usuario,
      );
      expect(roundTrip.id, evento.id);
      expect(roundTrip.titulo, evento.titulo);
      expect(roundTrip.tipo.id, evento.tipo.id);
      expect(
        roundTrip.fechaHoraInicio.toIso8601String(),
        evento.fechaHoraInicio.toIso8601String(),
      );
      expect(
        roundTrip.fechaHoraFin?.toIso8601String(),
        evento.fechaHoraFin?.toIso8601String(),
      );
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = EventoAgendaModel.fromJson(json);
      final entity = EventoAgendaMapper.fromModel(
        modelFromJson,
        persona: persona,
        creadoPor: usuario,
      );
      final modelBack = EventoAgendaMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });

    test('fechaHoraFin nulo se preserva en round-trip', () {
      final eventoSinFin = EventoAgenda(
        id: evento.id,
        persona: evento.persona,
        creadoPor: evento.creadoPor,
        titulo: evento.titulo,
        descripcion: evento.descripcion,
        tipo: evento.tipo,
        fechaHoraInicio: evento.fechaHoraInicio,
        fechaHoraFin: null,
      );
      final roundTrip = EventoAgendaMapper.fromModel(
        EventoAgendaMapper.toModel(eventoSinFin),
        persona: persona,
        creadoPor: usuario,
      );
      expect(roundTrip.fechaHoraFin, isNull);
    });
  });

  group('RecordatorioMapper', () {
    final evento = EventoAgenda(
      id: 702,
      persona: persona,
      creadoPor: usuario,
      titulo: 'Medicación',
      tipo: tipoMedicacion,
      fechaHoraInicio: DateTime(2026, 6, 7, 8, 0),
    );

    final recordatorio = Recordatorio(
      id: 801,
      eventoAgenda: evento,
      fechaHoraEnvio: DateTime(2026, 6, 7, 7, 30),
      enviado: false,
    );

    final model = RecordatorioModel(
      id: 801,
      eventoAgendaId: 702,
      fechaHoraEnvio: '2026-06-07T07:30:00.000',
      enviado: false,
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = RecordatorioMapper.fromModel(
        RecordatorioMapper.toModel(recordatorio),
        evento,
      );
      expect(roundTrip.id, recordatorio.id);
      expect(roundTrip.enviado, recordatorio.enviado);
      expect(
        roundTrip.fechaHoraEnvio.toIso8601String(),
        recordatorio.fechaHoraEnvio.toIso8601String(),
      );
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = RecordatorioModel.fromJson(json);
      final entity = RecordatorioMapper.fromModel(modelFromJson, evento);
      final modelBack = RecordatorioMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });
  });
}
