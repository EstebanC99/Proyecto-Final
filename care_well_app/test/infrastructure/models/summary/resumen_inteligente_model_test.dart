import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// JSON completo, con la forma que devuelve `ResumenDiarioDataView`.
Map<String, dynamic> _jsonCompleto() => {
  'resumenAcotado': 'Jornada tranquila.',
  'estadoAnimo': 'Alegre y con energía',
  'resumenHabitos': 'Buen día de rutina.',
  'habitos': [
    {'descripcion': 'Paseo matutino', 'completado': true},
    {'descripcion': 'Cena', 'completado': false},
  ],
  'eventosSalud': [
    {
      'descripcion': 'Salida para hacer pis',
      'hora': '12:15:00',
      'actividadHabitoAsociado': null,
    },
  ],
  'recomendaciones': ['Vigilá la digestión.'],
  'recordatoriosHoy': ['Dar la medicación de la noche'],
  'recordatoriosManana': ['Turno con el veterinario'],
  'habitosManana': [
    {'descripcion': 'Paseo matutino', 'completado': false},
  ],
  'generadoEn': '2026-08-08T20:21:00',
  'tieneDatos': true,
};

void main() {
  group('ResumenInteligenteModel.fromJson', () {
    test('parsea el JSON completo', () {
      final model = ResumenInteligenteModel.fromJson(_jsonCompleto());

      expect(model.resumenAcotado, 'Jornada tranquila.');
      expect(model.estadoAnimo, 'Alegre y con energía');
      expect(model.resumenHabitos, 'Buen día de rutina.');
      expect(model.habitos, hasLength(2));
      expect(model.habitos.first.descripcion, 'Paseo matutino');
      expect(model.habitos.first.completado, isTrue);
      expect(model.eventosSalud.single.hora, '12:15:00');
      expect(model.eventosSalud.single.actividadHabitoAsociado, isNull);
      expect(model.recomendaciones, ['Vigilá la digestión.']);
      expect(model.recordatoriosHoy, hasLength(1));
      expect(model.recordatoriosManana, hasLength(1));
      expect(model.habitosManana.single.completado, isFalse);
      expect(model.generadoEn, DateTime(2026, 8, 8, 20, 21));
      expect(model.tieneDatos, isTrue);
    });

    test('las listas ausentes o nulas quedan vacías', () {
      final model = ResumenInteligenteModel.fromJson({
        'resumenAcotado': 'Algo.',
        'habitos': null,
        'generadoEn': '2026-08-08T20:21:00',
        'tieneDatos': true,
      });

      expect(model.habitos, isEmpty);
      expect(model.eventosSalud, isEmpty);
      expect(model.recomendaciones, isEmpty);
      expect(model.recordatoriosHoy, isEmpty);
      expect(model.recordatoriosManana, isEmpty);
      expect(model.habitosManana, isEmpty);
    });

    test('un JSON vacío no rompe y da tieneDatos false', () {
      final model = ResumenInteligenteModel.fromJson({});

      expect(model.resumenAcotado, isNull);
      expect(model.generadoEn, isNull);
      expect(model.tieneDatos, isFalse);
    });

    test('deriva tieneDatos cuando el campo no viene', () {
      final json = _jsonCompleto()..remove('tieneDatos');

      expect(ResumenInteligenteModel.fromJson(json).tieneDatos, isTrue);
    });

    test('descarta textos vacíos y elementos con otra forma', () {
      final model = ResumenInteligenteModel.fromJson({
        'resumenAcotado': '   ',
        'recomendaciones': ['', 'Una válida', null, 7],
        'habitos': ['no soy un objeto'],
        'tieneDatos': true,
      });

      expect(model.resumenAcotado, isNull);
      expect(model.recomendaciones, ['Una válida']);
      expect(model.habitos, isEmpty);
    });

    test('generadoEn inválido o DateTime.MinValue queda en null', () {
      final invalida = ResumenInteligenteModel.fromJson({
        'generadoEn': 'no es una fecha',
        'tieneDatos': false,
      });
      final minValue = ResumenInteligenteModel.fromJson({
        'generadoEn': '0001-01-01T00:00:00',
        'tieneDatos': false,
      });

      expect(invalida.generadoEn, isNull);
      expect(minValue.generadoEn, isNull);
    });

    test('un hábito sin completado se asume pendiente', () {
      final model = ResumenInteligenteModel.fromJson({
        'habitos': [
          {'descripcion': 'Paseo'},
        ],
        'tieneDatos': true,
      });

      expect(model.habitos.single.completado, isFalse);
    });
  });
}
