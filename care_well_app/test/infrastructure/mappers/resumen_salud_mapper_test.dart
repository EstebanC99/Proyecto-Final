import 'package:care_well_app/infrastructure/mappers/mappers.dart';
import 'package:care_well_app/infrastructure/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// JSON completo tal como lo serializa `ResumenSaludDataView`.
const _jsonCompleto = <String, dynamic>{
  'grupoSanguineo': '0+',
  'cantidadAlergias': 2,
  'cantidadAntecedentes': 1,
  'cantidadEnfermedades': 3,
  'cantidadHabitosCompletados': 2,
  'cantidadHabitos': 5,
  'estadoAnimoID': 4,
  'ultimoEventoSalud': 'Dolor de garganta',
  'cantidadDias': 3,
};

/// Persona sin ficha, sin hábitos, sin ánimo de hoy y sin eventos: el backend
/// devuelve nulos (y 0 días, que no significa "hoy").
const _jsonVacio = <String, dynamic>{
  'grupoSanguineo': null,
  'cantidadAlergias': null,
  'cantidadAntecedentes': null,
  'cantidadEnfermedades': null,
  'cantidadHabitosCompletados': 0,
  'cantidadHabitos': 0,
  'estadoAnimoID': null,
  'ultimoEventoSalud': null,
  'cantidadDias': 0,
};

void main() {
  group('ResumenSaludModel.fromJson', () {
    test('mapea todos los campos del JSON completo', () {
      final model = ResumenSaludModel.fromJson(_jsonCompleto);

      expect(model.grupoSanguineo, '0+');
      expect(model.cantidadAlergias, 2);
      expect(model.cantidadAntecedentes, 1);
      expect(model.cantidadEnfermedades, 3);
      expect(model.cantidadHabitosCompletados, 2);
      expect(model.cantidadHabitos, 5);
      expect(model.estadoAnimoId, 4);
      expect(model.ultimoEventoSalud, 'Dolor de garganta');
      expect(model.cantidadDias, 3);
    });

    test('tolera un JSON con todos los campos ausentes', () {
      final model = ResumenSaludModel.fromJson(const {});

      expect(model.grupoSanguineo, isNull);
      expect(model.cantidadHabitos, isNull);
      expect(model.estadoAnimoId, isNull);
      expect(model.cantidadDias, isNull);
    });
  });

  group('ResumenSaludMapper.fromModel', () {
    test('traslada los datos del resumen completo', () {
      final resumen = ResumenSaludMapper.fromModel(
        ResumenSaludModel.fromJson(_jsonCompleto),
      );

      expect(resumen.grupoSanguineo, '0+');
      expect(resumen.cantidadAlergias, 2);
      expect(resumen.cantidadAntecedentes, 1);
      expect(resumen.cantidadEnfermedades, 3);
      expect(resumen.cantidadHabitosCompletados, 2);
      expect(resumen.cantidadHabitos, 5);
      expect(resumen.estadoAnimoId, 4);
      expect(resumen.ultimoEventoSalud, 'Dolor de garganta');
      expect(resumen.diasDesdeUltimoEvento, 3);
      expect(resumen.tieneFicha, isTrue);
      expect(resumen.tieneHabitos, isTrue);
      expect(resumen.tieneEventos, isTrue);
    });

    // Sin evento el backend manda 0 días; tomarlo al pie de la letra haría que
    // la tarjeta dijera "Último: hoy" cuando en realidad no hay ningún evento.
    test('sin evento descarta los 0 días que manda el backend', () {
      final resumen = ResumenSaludMapper.fromModel(
        ResumenSaludModel.fromJson(_jsonVacio),
      );

      expect(resumen.ultimoEventoSalud, isNull);
      expect(resumen.diasDesdeUltimoEvento, isNull);
      expect(resumen.tieneEventos, isFalse);
    });

    test('sin ficha cargada los recuentos quedan nulos', () {
      final resumen = ResumenSaludMapper.fromModel(
        ResumenSaludModel.fromJson(_jsonVacio),
      );

      expect(resumen.tieneFicha, isFalse);
      expect(resumen.grupoSanguineo, isNull);
      expect(resumen.cantidadAlergias, isNull);
    });

    test('una ficha sin elementos no se confunde con la ausencia de ficha', () {
      final resumen = ResumenSaludMapper.fromModel(
        ResumenSaludModel.fromJson(const {
          'grupoSanguineo': 'AB-',
          'cantidadAlergias': 0,
          'cantidadAntecedentes': 0,
          'cantidadEnfermedades': 0,
        }),
      );

      expect(resumen.tieneFicha, isTrue);
      expect(resumen.cantidadAlergias, 0);
    });

    test('sin hábitos cargados tieneHabitos es falso', () {
      final resumen = ResumenSaludMapper.fromModel(
        ResumenSaludModel.fromJson(_jsonVacio),
      );

      expect(resumen.tieneHabitos, isFalse);
    });
  });
}
