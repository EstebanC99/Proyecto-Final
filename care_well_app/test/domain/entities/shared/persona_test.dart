import 'package:care_well_app/domain/entities/shared/persona.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Persona.copyWith', () {
    final base = Persona(
      id: 1,
      nombre: 'Ana',
      apellido: 'López',
      documento: '12345678',
      fechaNacimiento: DateTime(1990, 5, 20),
      email: 'ana@example.com',
      telefono: '+54 9 11 9876-5432',
      imagen: 'iVBORw0KGgo=',
    );

    test('preserva email, telefono e imagen cuando no se pasan', () {
      final copia = base.copyWith(nombre: 'Ana María');

      expect(copia.nombre, 'Ana María');
      expect(copia.email, 'ana@example.com');
      expect(copia.telefono, '+54 9 11 9876-5432');
      expect(copia.imagen, 'iVBORw0KGgo=');
    });

    test('reemplaza los campos que sí se pasan', () {
      final copia = base.copyWith(
        email: 'nuevo@example.com',
        telefono: '+54 9 11 0000-0000',
        imagen: 'bmV3aW1hZ2U=',
      );

      expect(copia.email, 'nuevo@example.com');
      expect(copia.telefono, '+54 9 11 0000-0000');
      expect(copia.imagen, 'bmV3aW1hZ2U=');
    });
  });
}
