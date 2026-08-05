import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Respuesta real de `POST /api/Emergencia/obtener` (un elemento del array).
Map<String, dynamic> _json({String? descripcion}) => {
  'id': 7,
  'persona': {
    'id': 12,
    'nombre': 'Maria',
    'apellido': 'G.',
    'documento': '30111222',
    'fechaNacimiento': '1945-03-02T00:00:00',
    'email': null,
    'telefono': null,
  },
  'activador': {
    'id': 3,
    'nombre': 'Esteban',
    'apellido': 'C.',
    'documento': '40111222',
    'fechaNacimiento': '1999-01-01T00:00:00',
    'email': 'esteban@mail.com',
    'telefono': null,
  },
  'fechaHora': '2026-08-05T14:32:10',
  'descripcion': descripcion,
};

void main() {
  group('EmergenciaMapper', () {
    test('json → entity mapea persona, activador y fecha', () {
      final entity = EmergenciaMapper.fromModel(
        EmergenciaModel.fromJson(_json(descripcion: 'Caída en el baño.')),
      );

      expect(entity.id, 7);
      expect(entity.persona.id, 12);
      expect(entity.persona.nombre, 'Maria');
      expect(entity.activador.id, 3);
      expect(entity.activador.nombre, 'Esteban');
      expect(entity.activador.email, 'esteban@mail.com');
      expect(entity.descripcion, 'Caída en el baño.');
      // ISO-8601 sin offset: se interpreta como hora local, sin desplazamiento.
      expect(entity.fechaHora, DateTime(2026, 8, 5, 14, 32, 10));
    });

    test('descripcion nula se preserva', () {
      final entity = EmergenciaMapper.fromModel(
        EmergenciaModel.fromJson(_json()),
      );

      expect(entity.descripcion, isNull);
    });

    test('la persona cuidada y el activador son distintos', () {
      final entity = EmergenciaMapper.fromModel(
        EmergenciaModel.fromJson(_json()),
      );

      expect(entity.persona.id, isNot(entity.activador.id));
    });
  });
}
