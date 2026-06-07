import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PersonaMapper', () {
    final persona = Persona(
      id: 'per_001',
      nombre: 'Ana',
      apellido: 'López',
      documento: '12345678',
      fechaNacimiento: DateTime(1990, 5, 20),
      email: 'ana@example.com',
      telefono: '+54 9 11 9876-5432',
      imagen: null,
    );

    final model = PersonaModel(
      id: 'per_001',
      nombre: 'Ana',
      apellido: 'López',
      documento: '12345678',
      fechaNacimiento: '1990-05-20T00:00:00.000',
      email: 'ana@example.com',
      telefono: '+54 9 11 9876-5432',
      imagen: null,
    );

    test('entity → model → entity produce entidad equivalente', () {
      final roundTrip = PersonaMapper.fromModel(PersonaMapper.toModel(persona));
      expect(roundTrip.id, persona.id);
      expect(roundTrip.nombre, persona.nombre);
      expect(roundTrip.apellido, persona.apellido);
      expect(roundTrip.documento, persona.documento);
      expect(
        roundTrip.fechaNacimiento?.toIso8601String(),
        persona.fechaNacimiento?.toIso8601String(),
      );
      expect(roundTrip.email, persona.email);
      expect(roundTrip.telefono, persona.telefono);
    });

    test('json → model → entity → model → json produce el mismo JSON', () {
      final json = model.toJson();
      final modelFromJson = PersonaModel.fromJson(json);
      final entity = PersonaMapper.fromModel(modelFromJson);
      final modelBack = PersonaMapper.toModel(entity);
      expect(modelBack.toJson(), json);
    });

    test('campos opcionales nulos se preservan en round-trip', () {
      final sinOpcionales = Persona(
        id: 'per_002',
        nombre: 'Juan',
        apellido: 'Pérez',
      );
      final roundTrip = PersonaMapper.fromModel(
        PersonaMapper.toModel(sinOpcionales),
      );
      expect(roundTrip.documento, isNull);
      expect(roundTrip.fechaNacimiento, isNull);
      expect(roundTrip.email, isNull);
      expect(roundTrip.telefono, isNull);
    });

    test('telefono se serializa y deserializa correctamente en JSON', () {
      final json = model.toJson();
      expect(json['telefono'], '+54 9 11 9876-5432');

      final modelSinTelefono = PersonaModel(
        id: 'per_003',
        nombre: 'Carlos',
        apellido: 'Gómez',
      );
      final jsonSinTelefono = modelSinTelefono.toJson();
      expect(jsonSinTelefono.containsKey('telefono'), isFalse);
    });

    test('telefono null no aparece en toJson', () {
      final personaSinTelefono = Persona(
        id: 'per_003',
        nombre: 'Carlos',
        apellido: 'Gómez',
        email: 'carlos@example.com',
      );
      final modelSinTelefono = PersonaMapper.toModel(personaSinTelefono);
      final json = modelSinTelefono.toJson();
      expect(json.containsKey('telefono'), isFalse);
    });
  });
}
