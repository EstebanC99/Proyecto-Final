import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final persona = Persona(
    id: 'per_001',
    nombre: 'Alicia',
    apellido: 'Rodríguez',
  );

  group('FichaSaludMapper', () {
    final ficha = FichaSalud(
      id: 'fis_001',
      persona: persona,
      antecedentes: 'Hipertensión arterial.',
      estudios: 'ECG normal.',
    );

    final model = FichaSaludModel(
      id: 'fis_001',
      personaId: 'per_001',
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
        id: 'fis_002',
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
    final habito = HabitoDeVida(
      id: 'hab_001',
      persona: persona,
      tipo: TipoHabito.actividadFisica,
      descripcion: 'Caminata diaria.',
    );

    final model = HabitoDeVidaModel(
      id: 'hab_001',
      personaId: 'per_001',
      tipo: 'actividadFisica',
      descripcion: 'Caminata diaria.',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = HabitoDeVidaMapper.fromModel(
        HabitoDeVidaMapper.toModel(habito),
        persona,
      );
      expect(roundTrip.id, habito.id);
      expect(roundTrip.tipo, habito.tipo);
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
      id: 'rec_001',
      persona: persona,
      descripcion: 'Controlar presión arterial.',
      fecha: DateTime(2026, 5, 15),
      profesional: 'Dr. Hernández',
    );

    final model = RecomendacionMedicaModel(
      id: 'rec_001',
      personaId: 'per_001',
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
    final evento = EventoDeSalud(
      id: 'esa_001',
      persona: persona,
      tipo: TipoEventoSalud.sintoma,
      fecha: DateTime(2026, 5, 28),
      descripcion: 'Episodio de mareos.',
    );

    final model = EventoDeSaludModel(
      id: 'esa_001',
      personaId: 'per_001',
      tipo: 'sintoma',
      fecha: '2026-05-28T00:00:00.000',
      descripcion: 'Episodio de mareos.',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = EventoDeSaludMapper.fromModel(
        EventoDeSaludMapper.toModel(evento),
        persona,
      );
      expect(roundTrip.id, evento.id);
      expect(roundTrip.tipo, evento.tipo);
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
    final evento = EventoDeSalud(
      id: 'esa_001',
      persona: persona,
      tipo: TipoEventoSalud.sintoma,
      fecha: DateTime(2026, 5, 28),
      descripcion: 'Mareos.',
    );

    final estadoConEvento = EstadoDeAnimo(
      id: 'ani_001',
      persona: persona,
      eventoDeSalud: evento,
      fecha: DateTime(2026, 5, 28),
      estado: EstadoAnimoEnum.mal,
      observaciones: 'Preocupada.',
    );

    final model = EstadoDeAnimoModel(
      id: 'ani_001',
      personaId: 'per_001',
      eventoDeSaludId: 'esa_001',
      fecha: '2026-05-28T00:00:00.000',
      estado: 'mal',
      observaciones: 'Preocupada.',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = EstadoDeAnimoMapper.fromModel(
        EstadoDeAnimoMapper.toModel(estadoConEvento),
        persona,
        eventoDeSalud: evento,
      );
      expect(roundTrip.id, estadoConEvento.id);
      expect(roundTrip.estado, estadoConEvento.estado);
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
        id: 'ani_002',
        persona: persona,
        fecha: DateTime(2026, 6, 4),
        estado: EstadoAnimoEnum.bien,
      );
      final roundTrip = EstadoDeAnimoMapper.fromModel(
        EstadoDeAnimoMapper.toModel(sinEvento),
        persona,
      );
      expect(roundTrip.eventoDeSalud, isNull);
    });
  });
}
