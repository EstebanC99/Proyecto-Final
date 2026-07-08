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
      factorSanguineo: 'O+',
      obraSocial: 'PAMI',
      observaciones: 'Controlar presión.',
      antecedentes: const [
        FichaSaludAntecedente(
          id: 511,
          nombre: 'Hipertensión',
          descripcion: 'Diagnosticada en 2015.',
          vinculoFamiliar: 'Madre',
        ),
      ],
      alergias: const [
        FichaSaludAlergia(
          id: 521,
          nombre: 'Penicilina',
          reaccion: 'Erupción cutánea.',
          medicamento: 'Amoxicilina',
        ),
      ],
      enfermedades: const [
        FichaSaludEnfermedad(
          id: 531,
          nombre: 'Hipotiroidismo',
          vigente: true,
          observacion: 'Controlada.',
        ),
      ],
    );

    final model = FichaSaludModel(
      id: 501,
      personaId: 1,
      factorSanguineo: 'O+',
      obraSocial: 'PAMI',
      observaciones: 'Controlar presión.',
      antecedentes: const [
        FichaSaludAntecedenteModel(
          id: 511,
          nombre: 'Hipertensión',
          descripcion: 'Diagnosticada en 2015.',
          vinculoFamiliar: 'Madre',
        ),
      ],
      alergias: const [
        FichaSaludAlergiaModel(
          id: 521,
          nombre: 'Penicilina',
          reaccion: 'Erupción cutánea.',
          medicamento: 'Amoxicilina',
        ),
      ],
      enfermedades: const [
        FichaSaludEnfermedadModel(
          id: 531,
          nombre: 'Hipotiroidismo',
          vigente: true,
          observacion: 'Controlada.',
        ),
      ],
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = FichaSaludMapper.fromModel(
        FichaSaludMapper.toModel(ficha),
        persona,
      );
      expect(roundTrip.id, ficha.id);
      expect(roundTrip.factorSanguineo, ficha.factorSanguineo);
      expect(roundTrip.obraSocial, ficha.obraSocial);
      expect(roundTrip.observaciones, ficha.observaciones);
      expect(roundTrip.antecedentes.single.nombre, 'Hipertensión');
      expect(roundTrip.antecedentes.single.vinculoFamiliar, 'Madre');
      expect(roundTrip.alergias.single.medicamento, 'Amoxicilina');
      expect(roundTrip.enfermedades.single.vigente, isTrue);
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
        factorSanguineo: 'A+',
      );
      final roundTrip = FichaSaludMapper.fromModel(
        FichaSaludMapper.toModel(sinCampos),
        persona,
      );
      expect(roundTrip.obraSocial, isNull);
      expect(roundTrip.observaciones, isNull);
      expect(roundTrip.antecedentes, isEmpty);
      expect(roundTrip.alergias, isEmpty);
      expect(roundTrip.enfermedades, isEmpty);
    });
  });

  group('HabitoVidaMapper', () {
    final model = HabitoVidaModel(
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
      final entity = HabitoVidaMapper.fromModel(model);
      expect(entity.id, 901);
      expect(entity.persona.id, 1);
      expect(entity.persona.descripcion, 'Alicia Rodríguez');
      expect(entity.tipo.id, TiposHabitoConst.actividadFisica);
      expect(entity.descripcion, 'Caminata diaria.');
      expect(entity.realizacion, isNull);
    });

    test('model con realizacion → entidad con realizacion', () {
      final modelConRealizacion = HabitoVidaModel(
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
      final entity = HabitoVidaMapper.fromModel(modelConRealizacion);
      expect(entity.realizacion, isNotNull);
      expect(entity.realizacion!.id, 9010);
      expect(entity.realizacion!.habitoId, 901);
      expect(entity.realizacion!.comentarios, 'Completada.');
    });
  });

  group('EventoDeSaludMapper', () {
    final refPersona = EntidadBasica(id: 1, descripcion: 'Alicia Rodríguez');

    final tipoSintoma = TipoEventoSalud(
      id: TiposEventoAgendaConst.sintoma,
      descripcion: 'Síntoma',
    );

    final evento = EventoSalud(
      id: 1101,
      persona: refPersona,
      tipo: tipoSintoma,
      fechaHora: DateTime(2026, 5, 28),
      descripcion: 'Episodio de mareos.',
    );

    final model = EventoSaludModel(
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
      final roundTrip = EventoSaludMapper.fromModel(
        EventoSaludMapper.toModel(evento),
      );
      expect(roundTrip.id, evento.id);
      expect(roundTrip.tipo.id, evento.tipo.id);
      expect(roundTrip.descripcion, evento.descripcion);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = EventoSaludModel.fromJson(json);
      final entity = EventoSaludMapper.fromModel(modelFromJson);
      final modelBack = EventoSaludMapper.toModel(entity);
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
