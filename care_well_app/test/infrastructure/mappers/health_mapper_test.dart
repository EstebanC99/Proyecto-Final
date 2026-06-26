import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final persona = Persona(id: 1, nombre: 'Alicia', apellido: 'Rodríguez', documento: "123123", fechaNacimiento: DateTime.now());

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
    final tipoActividadFisica = TipoHabito(
      id: TiposHabitoConst.actividadFisica,
      descripcion: 'Actividad física',
    );

    final habito = HabitoDeVida(
      id: 901,
      persona: persona,
      tipo: tipoActividadFisica,
      descripcion: 'Caminata diaria.',
    );

    final model = HabitoDeVidaModel(
      id: 901,
      personaId: 1,
      tipo: TipoHabitoModel(
        id: TiposHabitoConst.actividadFisica,
        descripcion: 'Actividad física',
      ),
      descripcion: 'Caminata diaria.',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = HabitoDeVidaMapper.fromModel(
        HabitoDeVidaMapper.toModel(habito),
        persona,
      );
      expect(roundTrip.id, habito.id);
      expect(roundTrip.tipo.id, habito.tipo.id);
      expect(roundTrip.descripcion, habito.descripcion);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = HabitoDeVidaModel.fromJson(json);
      final entity = HabitoDeVidaMapper.fromModel(modelFromJson, persona);
      final modelBack = HabitoDeVidaMapper.toModel(entity);
      expect(modelBack.toJson(), json);
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
    final tipoSintoma = TipoEventoSalud(
      id: TiposEventoSaludConst.sintoma,
      descripcion: 'Síntoma',
    );

    final evento = EventoDeSalud(
      id: 1101,
      persona: persona,
      tipo: tipoSintoma,
      fecha: DateTime(2026, 5, 28),
      descripcion: 'Episodio de mareos.',
    );

    final model = EventoDeSaludModel(
      id: 1101,
      personaId: 1,
      tipo: TipoEventoSaludModel(
        id: TiposEventoSaludConst.sintoma,
        descripcion: 'Síntoma',
      ),
      fecha: '2026-05-28T00:00:00.000',
      descripcion: 'Episodio de mareos.',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = EventoDeSaludMapper.fromModel(
        EventoDeSaludMapper.toModel(evento),
        persona,
      );
      expect(roundTrip.id, evento.id);
      expect(roundTrip.tipo.id, evento.tipo.id);
      expect(roundTrip.descripcion, evento.descripcion);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = EventoDeSaludModel.fromJson(json);
      final entity = EventoDeSaludMapper.fromModel(modelFromJson, persona);
      final modelBack = EventoDeSaludMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });
  });

  group('EstadoDeAnimoMapper', () {
    final tipoSintoma = TipoEventoSalud(
      id: TiposEventoSaludConst.sintoma,
      descripcion: 'Síntoma',
    );

    final estadoMal = EstadoAnimo(
      id: EstadosAnimoConst.mal,
      descripcion: 'Mal',
    );

    final estadoBien = EstadoAnimo(
      id: EstadosAnimoConst.bien,
      descripcion: 'Bien',
    );

    final evento = EventoDeSalud(
      id: 1101,
      persona: persona,
      tipo: tipoSintoma,
      fecha: DateTime(2026, 5, 28),
      descripcion: 'Mareos.',
    );

    final estadoConEvento = EstadoDeAnimo(
      id: 1201,
      persona: persona,
      eventoDeSalud: evento,
      fecha: DateTime(2026, 5, 28),
      estado: estadoMal,
      observaciones: 'Preocupada.',
    );

    final model = EstadoDeAnimoModel(
      id: 1201,
      personaId: 1,
      eventoDeSaludId: 1101,
      fecha: '2026-05-28T00:00:00.000',
      estado: EstadoAnimoModel(id: EstadosAnimoConst.mal, descripcion: 'Mal'),
      observaciones: 'Preocupada.',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = EstadoDeAnimoMapper.fromModel(
        EstadoDeAnimoMapper.toModel(estadoConEvento),
        persona,
        eventoDeSalud: evento,
      );
      expect(roundTrip.id, estadoConEvento.id);
      expect(roundTrip.estado.id, estadoConEvento.estado.id);
      expect(roundTrip.observaciones, estadoConEvento.observaciones);
      expect(roundTrip.eventoDeSalud?.id, evento.id);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = EstadoDeAnimoModel.fromJson(json);
      final entity = EstadoDeAnimoMapper.fromModel(
        modelFromJson,
        persona,
        eventoDeSalud: evento,
      );
      final modelBack = EstadoDeAnimoMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });

    test('eventoDeSalud nulo se preserva en round-trip', () {
      final sinEvento = EstadoDeAnimo(
        id: 1202,
        persona: persona,
        fecha: DateTime(2026, 6, 4),
        estado: estadoBien,
      );
      final roundTrip = EstadoDeAnimoMapper.fromModel(
        EstadoDeAnimoMapper.toModel(sinEvento),
        persona,
      );
      expect(roundTrip.eventoDeSalud, isNull);
    });
  });
}
