import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

EventoBase _evento({
  int id = 1,
  String categoria = 'Hábito',
  required DateTime fechaHora,
  String descripcion = 'Registro',
}) => EventoBase(
  id: id,
  descripcion: descripcion,
  categoriaEvento: categoria,
  fechaHora: fechaHora,
);

void main() {
  group('agruparPorDia', () {
    test('sin eventos devuelve una lista vacía', () {
      expect(agruparPorDia([]), isEmpty);
    });

    test('un solo evento forma un único grupo', () {
      final grupos = agruparPorDia([
        _evento(fechaHora: DateTime(2026, 8, 18, 9, 30)),
      ]);

      expect(grupos, hasLength(1));
      expect(grupos.single.dia, DateTime(2026, 8, 18));
      expect(grupos.single.eventos, hasLength(1));
    });

    test('los días quedan del más reciente al más antiguo', () {
      final grupos = agruparPorDia([
        _evento(id: 1, fechaHora: DateTime(2026, 8, 16, 10)),
        _evento(id: 2, fechaHora: DateTime(2026, 8, 18, 10)),
        _evento(id: 3, fechaHora: DateTime(2026, 8, 17, 10)),
      ]);

      expect(grupos.map((g) => g.dia).toList(), [
        DateTime(2026, 8, 18),
        DateTime(2026, 8, 17),
        DateTime(2026, 8, 16),
      ]);
    });

    test('dentro del día los eventos van de la mañana a la noche', () {
      final grupos = agruparPorDia([
        _evento(id: 1, fechaHora: DateTime(2026, 8, 18, 20)),
        _evento(id: 2, fechaHora: DateTime(2026, 8, 18, 7, 15)),
        _evento(id: 3, fechaHora: DateTime(2026, 8, 18, 13)),
      ]);

      expect(grupos.single.eventos.map((e) => e.id).toList(), [2, 3, 1]);
    });

    test('agrupa registros de distintas categorías en el mismo día', () {
      final grupos = agruparPorDia([
        _evento(
          id: 1,
          categoria: 'Hábito',
          fechaHora: DateTime(2026, 8, 18, 8),
        ),
        _evento(id: 1, categoria: 'Ánimo', fechaHora: DateTime(2026, 8, 18, 9)),
        _evento(
          id: 2,
          categoria: 'Evento',
          fechaHora: DateTime(2026, 8, 18, 10),
        ),
      ]);

      // Los ids se repiten entre categorías: el agrupado no debe perder nada.
      expect(grupos, hasLength(1));
      expect(grupos.single.eventos, hasLength(3));
    });

    test('el día se calcula en hora local, no en UTC', () {
      // 2026-08-18 02:00 UTC. En un huso al oeste de Greenwich (el nuestro),
      // es todavía el 17 por la noche; truncando antes de convertir caería en
      // el día equivocado.
      final utc = DateTime.utc(2026, 8, 18, 2);
      final local = utc.toLocal();
      final diaEsperado = DateTime(local.year, local.month, local.day);

      final grupos = agruparPorDia([_evento(fechaHora: utc)]);

      expect(grupos.single.dia, diaEsperado);
    });

    test(
      'dos registros en UTC que caen en días locales distintos se separan',
      () {
        // Separados por 24 horas exactas: sea cual sea el huso, son dos días.
        final primero = DateTime.utc(2026, 8, 18, 12);
        final segundo = primero.add(const Duration(days: 1));

        final grupos = agruparPorDia([
          _evento(id: 1, fechaHora: primero),
          _evento(id: 2, fechaHora: segundo),
        ]);

        expect(grupos, hasLength(2));
        expect(grupos.first.eventos.single.id, 2); // el más reciente arriba
        expect(grupos.last.eventos.single.id, 1);
      },
    );
  });
}
