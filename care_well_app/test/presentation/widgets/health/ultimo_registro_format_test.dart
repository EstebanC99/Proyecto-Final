import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Presente fijo: mediodía, para que los desfasajes de hora no muevan el día.
  final ahora = DateTime(2026, 8, 12, 12, 30);

  String desdeHace(int dias) =>
      textoRelativoDesde(ahora.subtract(Duration(days: dias)), ahora: ahora);

  group('textoRelativoDesde', () {
    test('mismo día → hoy (sin importar la hora)', () {
      expect(desdeHace(0), 'hoy');
      expect(
        textoRelativoDesde(DateTime(2026, 8, 12, 0, 5), ahora: ahora),
        'hoy',
      );
      expect(
        textoRelativoDesde(DateTime(2026, 8, 12, 23, 55), ahora: ahora),
        'hoy',
      );
    });

    test('día anterior → ayer', () {
      expect(desdeHace(1), 'ayer');
    });

    test('2 a 6 días → hace N días', () {
      expect(desdeHace(2), 'hace 2 días');
      expect(desdeHace(6), 'hace 6 días');
    });

    test('7 a 13 días → hace 1 semana', () {
      expect(desdeHace(7), 'hace 1 semana');
      expect(desdeHace(13), 'hace 1 semana');
    });

    test('14 a 29 días → hace N semanas', () {
      expect(desdeHace(14), 'hace 2 semanas');
      expect(desdeHace(29), 'hace 4 semanas');
    });

    test('30 a 59 días → hace 1 mes', () {
      expect(desdeHace(30), 'hace 1 mes');
      expect(desdeHace(59), 'hace 1 mes');
    });

    test('60 a 364 días → hace N meses', () {
      expect(desdeHace(60), 'hace 2 meses');
      expect(desdeHace(364), 'hace 12 meses');
    });

    test('365 días o más → hace más de un año', () {
      expect(desdeHace(365), 'hace más de un año');
      expect(desdeHace(900), 'hace más de un año');
    });

    test('una fecha futura se muestra como hoy', () {
      expect(
        textoRelativoDesde(ahora.add(const Duration(days: 3)), ahora: ahora),
        'hoy',
      );
    });
  });

  // El resumen de salud del hub recibe los días ya calculados por el backend,
  // sin la fecha del registro.
  group('textoRelativoEnDias', () {
    test('cubre los mismos cortes que la variante por fecha', () {
      expect(textoRelativoEnDias(0), 'hoy');
      expect(textoRelativoEnDias(1), 'ayer');
      expect(textoRelativoEnDias(6), 'hace 6 días');
      expect(textoRelativoEnDias(7), 'hace 1 semana');
      expect(textoRelativoEnDias(14), 'hace 2 semanas');
      expect(textoRelativoEnDias(30), 'hace 1 mes');
      expect(textoRelativoEnDias(60), 'hace 2 meses');
      expect(textoRelativoEnDias(365), 'hace más de un año');
    });

    test('un valor negativo se trata como hoy', () {
      expect(textoRelativoEnDias(-5), 'hoy');
    });
  });
}
