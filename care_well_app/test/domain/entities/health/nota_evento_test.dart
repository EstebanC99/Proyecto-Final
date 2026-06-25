import 'package:care_well_app/domain/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final autor = Persona(id: 1, nombre: 'María', apellido: 'García');

  final nota = NotaEvento(
    id: 1301,
    eventoSaludId: 1101,
    autor: autor,
    fechaHora: DateTime(2026, 6, 2, 14, 32),
    contenido: 'Texto de la nota.',
  );

  group('NotaEvento', () {
    test('copyWith reemplaza solo los campos indicados', () {
      final copia = nota.copyWith(contenido: 'Nuevo contenido');
      expect(copia.id, nota.id);
      expect(copia.eventoSaludId, nota.eventoSaludId);
      expect(copia.autor, nota.autor);
      expect(copia.fechaHora, nota.fechaHora);
      expect(copia.contenido, 'Nuevo contenido');
    });

    test('copyWith sin argumentos retorna objeto igual', () {
      final copia = nota.copyWith();
      expect(copia, equals(nota));
    });

    test('igualdad por id y runtimeType', () {
      final otra = NotaEvento(
        id: 1301,
        eventoSaludId: 1102, // distinto eventoId
        autor: autor,
        fechaHora: DateTime.now(),
        contenido: 'Otro contenido',
      );
      expect(nota, equals(otra));
    });

    test('hashCode consistente con ==', () {
      final otra = NotaEvento(
        id: 1301,
        eventoSaludId: 1101,
        autor: autor,
        fechaHora: DateTime(2026, 6, 2, 14, 32),
        contenido: 'Texto de la nota.',
      );
      expect(nota.hashCode, equals(otra.hashCode));
    });

    test('ids distintos producen objetos distintos', () {
      final distinta = nota.copyWith(id: 1399);
      expect(nota, isNot(equals(distinta)));
    });
  });
}
