import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

/// Fake de [SummaryRepository] que cuenta las invocaciones para verificar la
/// regeneración por invalidación.
class _FakeSummaryRepository implements SummaryRepository {
  int llamadas = 0;

  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  }) async {
    llamadas++;
    return ResumenInteligente(
      texto: 'Resumen #$llamadas para $personaId.',
      tieneDatos: true,
      generadoEn: DateTime(2026, 7, 30, 10),
    );
  }
}

void main() {
  group('resumenInteligenteProvider', () {
    test('resuelve null cuando no hay persona de contexto', () async {
      final container = ProviderContainer(
        overrides: [
          personaVisualizacionSeleccionadaProvider.overrideWith(
            (ref) async => null,
          ),
          summaryRepositoryProvider.overrideWithValue(_FakeSummaryRepository()),
        ],
      );
      addTearDown(container.dispose);

      final res = await container.read(resumenInteligenteProvider.future);
      expect(res, isNull);
    });

    test(
      'devuelve el resumen del repositorio para la persona de contexto',
      () async {
        final repo = _FakeSummaryRepository();
        final container = ProviderContainer(
          overrides: [
            personaVisualizacionSeleccionadaProvider.overrideWith(
              (ref) async => _personaAlicia,
            ),
            summaryRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        final res = await container.read(resumenInteligenteProvider.future);
        expect(res, isNotNull);
        expect(res!.tieneDatos, isTrue);
        expect(res.texto, contains('para 2'));
        expect(repo.llamadas, 1);
      },
    );

    test('invalidar el provider fuerza una nueva generación', () async {
      final repo = _FakeSummaryRepository();
      final container = ProviderContainer(
        overrides: [
          personaVisualizacionSeleccionadaProvider.overrideWith(
            (ref) async => _personaAlicia,
          ),
          summaryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      // Mantiene vivo el provider autoDispose durante el test.
      container.listen(resumenInteligenteProvider, (_, _) {});

      await container.read(resumenInteligenteProvider.future);
      expect(repo.llamadas, 1);

      container.invalidate(resumenInteligenteProvider);
      await container.read(resumenInteligenteProvider.future);
      expect(repo.llamadas, 2);
    });
  });
}
