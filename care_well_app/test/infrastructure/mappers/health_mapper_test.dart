import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final persona = Persona(
    id: 1,
    nombre: 'Alicia',
    apellido: 'Rodríguez',
    documento: "123123",
    fechaNacimiento: DateTime.now(),
  );

  group('FichaSaludMapper', () {
    final ficha = FichaSalud(
      id: 501,
      persona: persona,
      antecedentes: 'Hipertensión arterial.',
      estudios: 'ECG normal.',
    );

    final model = FichaSaludModel(
      id: 501,
      personaId: 1,
      antecedentes: 'Hipertensión arterial.',
      estudios: 'ECG normal.',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = FichaSaludMapper.fromModel(
        FichaSaludMapper.toModel(ficha),
        persona,
      );
      expect(roundTrip.id, ficha.id);
      expect(roundTrip.antecedentes, ficha.antecedentes);
      expect(roundTrip.estudios, ficha.estudios);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = FichaSaludModel.fromJson(json);
      final entity = FichaSaludMapper.fromModel(modelFromJson, persona);
      final modelBack = FichaSaludMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });

    test('campos opcionales nulos se preservan en round-trip', () {
      final sinCampos = FichaSalud(
        id: 502,
        persona: persona,
        antecedentes: null,
        estudios: null,
      );
      final roundTrip = FichaSaludMapper.fromModel(
        FichaSaludMapper.toModel(sinCampos),
        persona,
      );
      expect(roundTrip.antecedentes, isNull);
      expect(roundTrip.estudios, isNull);
    });
  });

  group('HabitoDeVidaMapper', () {
    final model = HabitoDeVidaModel(
      id: 901,
      persona: EntidadBasicaModel(id: 1, descripcion: 'Alicia Rodríguez'),
      tipo: EntidadBasicaModel(
        id: TiposHabitoConst.actividadFisica,
        descripcion: 'Actividad física',
      ),
      descripcion: 'Caminata diaria.',
      activo: true,
      realizacion: null,
    );

    test('model → entity mapea correctamente todos los campos', () {
      final entity = HabitoDeVidaMapper.fromModel(model);
      expect(entity.id, 901);
      expect(entity.persona.id, 1);
      expect(entity.persona.descripcion, 'Alicia Rodríguez');
      expect(entity.tipo.id, TiposHabitoConst.actividadFisica);
      expect(entity.descripcion, 'Caminata diaria.');
      expect(entity.realizacion, isNull);
    });

    test('model con realizacion → entidad con realizacion', () {
      final modelConRealizacion = HabitoDeVidaModel(
        id: 901,
        persona: EntidadBasicaModel(id: 1, descripcion: 'Alicia Rodríguez'),
        tipo: EntidadBasicaModel(
          id: TiposHabitoConst.actividadFisica,
          descripcion: 'Actividad física',
        ),
        descripcion: 'Caminata diaria.',
        activo: true,
        realizacion: HabitoVidaRealizacionModel(
          id: 9010,
          comentarios: 'Completada.',
          fechaHoraRealizacion: '2026-07-03T08:30:00.000',
        ),
      );
      final entity = HabitoDeVidaMapper.fromModel(modelConRealizacion);
      expect(entity.realizacion, isNotNull);
      expect(entity.realizacion!.id, 9010);
      expect(entity.realizacion!.habitoId, 901);
      expect(entity.realizacion!.comentarios, 'Completada.');
    });
  });

  group('RecomendacionMedicaMapper', () {
    final recomendacion = RecomendacionMedica(
      id: 1001,
      persona: persona,
      descripcion: 'Controlar presión arterial.',
      fecha: DateTime(2026, 5, 15),
      profesional: 'Dr. Hernández',
    );

    final model = RecomendacionMedicaModel(
      id: 1001,
      personaId: 1,
      descripcion: 'Controlar presión arterial.',
      fecha: '2026-05-15T00:00:00.000',
      profesional: 'Dr. Hernández',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = RecomendacionMedicaMapper.fromModel(
        RecomendacionMedicaMapper.toModel(recomendacion),
        persona,
      );
      expect(roundTrip.id, recomendacion.id);
      expect(roundTrip.descripcion, recomendacion.descripcion);
      expect(roundTrip.profesional, recomendacion.profesional);
      expect(
        roundTrip.fecha.toIso8601String(),
        recomendacion.fecha.toIso8601String(),
      );
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = RecomendacionMedicaModel.fromJson(json);
      final entity = RecomendacionMedicaMapper.fromModel(
        modelFromJson,
        persona,
      );
      final modelBack = RecomendacionMedicaMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });
  });

  group('EventoDeSaludMapper', () {
    final refPersona = EntidadBasica(id: 1, descripcion: 'Alicia Rodríguez');

    final tipoSintoma = TipoEventoSalud(
      id: TiposEventoAgendaConst.sintoma,
      descripcion: 'Síntoma',
    );

    final evento = EventoDeSalud(
      id: 1101,
      persona: refPersona,
      tipo: tipoSintoma,
      fechaHora: DateTime(2026, 5, 28),
      descripcion: 'Episodio de mareos.',
    );

    final model = EventoDeSaludModel(
      id: 1101,
      persona: EntidadBasicaModel(id: 1, descripcion: 'Alicia Rodríguez'),
      tipo: TipoEventoSaludModel(
        id: TiposEventoAgendaConst.sintoma,
        descripcion: 'Síntoma',
      ),
      fechaHora: '2026-05-28T00:00:00.000',
      descripcion: 'Episodio de mareos.',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = EventoDeSaludMapper.fromModel(
        EventoDeSaludMapper.toModel(evento),
      );
      expect(roundTrip.id, evento.id);
      expect(roundTrip.tipo.id, evento.tipo.id);
      expect(roundTrip.descripcion, evento.descripcion);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = EventoDeSaludModel.fromJson(json);
      final entity = EventoDeSaludMapper.fromModel(modelFromJson);
      final modelBack = EventoDeSaludMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });
  });

  group('PersonaEstadoAnimoMapper', () {
    final model = PersonaEstadoAnimoModel(
      id: 55,
      estadoAnimo: EstadoAnimoModel(
        id: EstadosAnimoConst.bien,
        descripcion: 'Bien',
      ),
      fechaHora: '2026-07-03T10:15:00',
      observaciones: 'Estuvo tranquila.',
    );

    test('model → entity mapea todos los campos', () {
      final entity = PersonaEstadoAnimoMapper.fromModel(model, persona);
      expect(entity.id, 55);
      expect(entity.estado.id, EstadosAnimoConst.bien);
      expect(entity.estado.descripcion, 'Bien');
      expect(entity.fecha, DateTime.parse('2026-07-03T10:15:00'));
      expect(entity.observaciones, 'Estuvo tranquila.');
      expect(entity.persona.id, persona.id);
    });

    test('eventoDeSalud siempre es null (los DataViews no lo traen)', () {
      final entity = PersonaEstadoAnimoMapper.fromModel(model, persona);
      expect(entity.eventoDeSalud, isNull);
    });

    test('observaciones nulas se preservan', () {
      final sinObs = PersonaEstadoAnimoModel(
        id: 56,
        estadoAnimo: EstadoAnimoModel(
          id: EstadosAnimoConst.regular,
          descripcion: 'Regular',
        ),
        fechaHora: '2026-07-03T09:00:00',
      );
      final entity = PersonaEstadoAnimoMapper.fromModel(sinObs, persona);
      expect(entity.observaciones, isNull);
    });
  });
}
