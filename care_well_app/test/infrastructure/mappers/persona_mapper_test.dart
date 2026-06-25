import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PersonaMapper', () {
    final model = PersonaModel(
      id: 1,
      nombre: 'Ana',
      apellido: 'López',
      documento: '12345678',
      fechaNacimiento: DateTime(1990, 5, 20),
      email: 'ana@example.com',
      telefono: '+54 9 11 9876-5432',
      imagenPath: null,
    );

    test('fromModel produce entidad con campos correctos', () {
      final entity = PersonaMapper.fromModel(model);
      expect(entity.id, 1);
      expect(entity.nombre, 'Ana');
      expect(entity.apellido, 'López');
      expect(entity.documento, '12345678');
      expect(entity.email, 'ana@example.com');
      expect(entity.telefono, '+54 9 11 9876-5432');
    });

    test('fromModel asigna fechaNacimiento correctamente', () {
      final entity = PersonaMapper.fromModel(model);
      expect(entity.fechaNacimiento, DateTime(1990, 5, 20));
    });

    test('json → model → entity produce entidad con id correcto', () {
      final json = {
        'id': 2,
        'nombre': 'Juan',
        'apellido': 'Pérez',
        'documento': '87654321',
        'fechaNacimiento': '1985-03-10T00:00:00.000',
        'email': 'juan@example.com',
        'telefono': '',
        'imagenPath': null,
      };
      final modelFromJson = PersonaModel.fromJson(json);
      final entity = PersonaMapper.fromModel(modelFromJson);
      expect(entity.id, 2);
      expect(entity.nombre, 'Juan');
    });
  });
}
