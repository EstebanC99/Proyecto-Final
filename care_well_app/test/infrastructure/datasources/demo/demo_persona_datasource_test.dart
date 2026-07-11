import 'package:care_well_app/infrastructure/datasources/demo/demo_persona_datasource.dart';
import 'package:care_well_app/infrastructure/datasources/demo/demo_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DemoPersonaDatasource.getImagen', () {
    late DemoPersonaDatasource datasource;

    setUp(() => datasource = DemoPersonaDatasource());

    test('devuelve null: el modo demo no simula imágenes de perfil', () async {
      final result = await datasource.getImagen(DemoSeed.personaMariaId);
      expect(result, isNull);
    });

    test('devuelve null también para un id inexistente', () async {
      final result = await datasource.getImagen(99999);
      expect(result, isNull);
    });
  });

  group('DemoPersonaDatasource.actualizar', () {
    late DemoPersonaDatasource datasource;

    setUp(() => datasource = DemoPersonaDatasource());

    test('reemplaza la persona en memoria, incluida la imagen', () async {
      final original = await datasource.getById(DemoSeed.personaMariaId);
      final modificada = original.copyWith(
        telefono: '+54 9 11 0000-0000',
        documento: '99999999',
        imagen: 'bWlfaW1hZ2Vu',
      );

      final resultado = await datasource.actualizar(modificada);

      expect(resultado.telefono, '+54 9 11 0000-0000');
      expect(resultado.documento, '99999999');
      expect(resultado.imagen, 'bWlfaW1hZ2Vu');

      // El cambio quedó persistido en memoria.
      final recuperada = await datasource.getById(DemoSeed.personaMariaId);
      expect(recuperada.telefono, '+54 9 11 0000-0000');
      expect(recuperada.documento, '99999999');
      expect(recuperada.imagen, 'bWlfaW1hZ2Vu');
    });

    test('lanza excepción si la persona no existe', () async {
      final original = await datasource.getById(DemoSeed.personaMariaId);
      final inexistente = original.copyWith(id: 99999);

      expect(
        () => datasource.actualizar(inexistente),
        throwsA(isA<Exception>()),
      );
    });
  });
}
