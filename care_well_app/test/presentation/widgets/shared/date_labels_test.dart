import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Miércoles 20 de agosto de 2025, media tarde.
  final hoy = DateTime(2025, 8, 20, 15, 30);

  group('rotuloRelativoDia', () {
    test('resuelve hoy, mañana y ayer', () {
      expect(rotuloRelativoDia(DateTime(2025, 8, 20), hoy: hoy), 'Hoy');
      expect(rotuloRelativoDia(DateTime(2025, 8, 21), hoy: hoy), 'Mañana');
      expect(rotuloRelativoDia(DateTime(2025, 8, 19), hoy: hoy), 'Ayer');
    });

    test('para el resto usa el nombre del día de la semana', () {
      // 23/08/2025 es sábado; 17/08/2025 es domingo.
      expect(rotuloRelativoDia(DateTime(2025, 8, 23), hoy: hoy), 'sábado');
      expect(rotuloRelativoDia(DateTime(2025, 8, 17), hoy: hoy), 'domingo');
    });

    test('ignora la hora al comparar', () {
      expect(rotuloRelativoDia(DateTime(2025, 8, 20, 23, 59), hoy: hoy), 'Hoy');
      expect(
        rotuloRelativoDia(DateTime(2025, 8, 21, 0, 1), hoy: hoy),
        'Mañana',
      );
    });

    test('funciona cruzando el cambio de mes', () {
      final finDeMes = DateTime(2025, 8, 31, 9);
      expect(rotuloRelativoDia(DateTime(2025, 9, 1), hoy: finDeMes), 'Mañana');
      expect(rotuloRelativoDia(DateTime(2025, 8, 30), hoy: finDeMes), 'Ayer');
    });
  });

  group('fechaCortaRelativa', () {
    test('antepone el rótulo relativo a la fecha corta', () {
      expect(
        fechaCortaRelativa(DateTime(2025, 8, 20), hoy: hoy),
        'Hoy, 20 ago',
      );
      expect(
        fechaCortaRelativa(DateTime(2025, 8, 19), hoy: hoy),
        'Ayer, 19 ago',
      );
      expect(
        fechaCortaRelativa(DateTime(2025, 8, 21), hoy: hoy),
        'Mañana, 21 ago',
      );
    });

    test('sin rótulo relativo muestra sólo día y mes abreviado', () {
      expect(fechaCortaRelativa(DateTime(2025, 8, 15), hoy: hoy), '15 ago');
      expect(fechaCortaRelativa(DateTime(2025, 1, 3), hoy: hoy), '3 ene');
      expect(fechaCortaRelativa(DateTime(2025, 12, 31), hoy: hoy), '31 dic');
    });
  });
}
