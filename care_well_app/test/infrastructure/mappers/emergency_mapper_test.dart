import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmergenciaMapper', () {
    final persona = Persona(
      id: 'per_001',
      nombre: 'Alicia',
      apellido: 'Rodríguez',
    );

    final emergencia = Emergencia(
      id: 'eme_001',
      persona: persona,
      fechaHora: DateTime(2026, 6, 5, 14, 30),
      atendida: false,
      descripcion: 'Caída en el baño.',
    );

    final model = EmergenciaModel(
      id: 'eme_001',
      personaId: 'per_001',
      fechaHora: '2026-06-05T14:30:00.000',
      atendida: false,
      descripcion: 'Caída en el baño.',
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = EmergenciaMapper.fromModel(
        EmergenciaMapper.toModel(emergencia),
        persona,
      );
      expect(roundTrip.id, emergencia.id);
      expect(roundTrip.atendida, emergencia.atendida);
      expect(roundTrip.descripcion, emergencia.descripcion);
      expect(
        roundTrip.fechaHora.toIso8601String(),
        emergencia.fechaHora.toIso8601String(),
      );
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = EmergenciaModel.fromJson(json);
      final entity = EmergenciaMapper.fromModel(modelFromJson, persona);
      final modelBack = EmergenciaMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });

    test('descripcion nula se preserva en round-trip', () {
      final sinDescripcion = Emergencia(
        id: 'eme_002',
        persona: persona,
        fechaHora: DateTime(2026, 6, 1, 9, 0),
        atendida: true,
        descripcion: null,
      );
      final roundTrip = EmergenciaMapper.fromModel(
        EmergenciaMapper.toModel(sinDescripcion),
        persona,
      );
      expect(roundTrip.descripcion, isNull);
      expect(roundTrip.atendida, isTrue);
    });
  });
}
