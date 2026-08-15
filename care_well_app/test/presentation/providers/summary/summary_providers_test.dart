import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/exceptions/exceptions.dart';
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

final _personaCarlos = Persona(
  id: 3,
  nombre: 'Carlos',
  apellido: 'Pérez',
  documento: '6111222',
  fechaNacimiento: DateTime(1940, 3, 4),
);

/// Fake de [SummaryRepository] que registra cada invocación para verificar el
/// flag con el que se pidió el resumen.
class _FakeSummaryRepository implements SummaryRepository {
  final List<({int personaId, bool forzarActualizacion})> llamadas = [];
  final bool falla;

  _FakeSummaryRepository({this.falla = false});

  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  }) async {
    llamadas.add((
      personaId: personaId,
      forzarActualizacion: forzarActualizacion,
    ));
    if (falla) throw const ServidorException();
    return ResumenInteligente(
      resumenAcotado: 'Resumen #${llamadas.length} para $personaId.',
      tieneDatos: true,
      generadoEn: DateTime(2026, 7, 30, 10),
    );
  }
}

/// Arma el container con la persona de contexto y el repositorio indicados.
ProviderContainer _container({
  required SummaryRepository repo,
  Persona? persona,
}) {
  // Sin `retry` propio a propósito: los tests de error dependen de que el
  // provider desactive el reintento automático de Riverpod (si no lo hiciera,
  // el estado quedaría en "loading" reintentando y el test se colgaría).
  final container = ProviderContainer(
    overrides: [
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => persona,
      ),
      summaryRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  // Mantiene vivo el provider autoDispose durante el test.
  container.listen(resumenInteligenteProvider, (_, _) {});
  return container;
}

void main() {
  group('resumenInteligenteProvider', () {
    test('la carga inicial no fuerza la actualización', () async {
      final repo = _FakeSummaryRepository();
      final container = _container(repo: repo, persona: _personaAlicia);

      final res = await container.read(resumenInteligenteProvider.future);

      expect(res, isNotNull);
      expect(res!.resumenAcotado, contains('para 2'));
      expect(repo.llamadas, hasLength(1));
      expect(repo.llamadas.single.personaId, 2);
      expect(repo.llamadas.single.forzarActualizacion, isFalse);
    });

    test('resuelve null y no consulta si no hay persona de contexto', () async {
      final repo = _FakeSummaryRepository();
      final container = _container(repo: repo);

      final res = await container.read(resumenInteligenteProvider.future);

      expect(res, isNull);
      expect(repo.llamadas, isEmpty);
    });

    test('refrescar() pide la regeneración y deja el estado en data', () async {
      final repo = _FakeSummaryRepository();
      final container = _container(repo: repo, persona: _personaAlicia);
      await container.read(resumenInteligenteProvider.future);

      await container.read(resumenInteligenteProvider.notifier).refrescar();

      expect(repo.llamadas, hasLength(2));
      expect(repo.llamadas.last.forzarActualizacion, isTrue);
      expect(
        container.read(resumenInteligenteProvider),
        isA<AsyncData<ResumenInteligente?>>(),
      );
      expect(
        container.read(resumenInteligenteProvider).value!.resumenAcotado,
        contains('#2'),
      );
    });

    test(
      'una falla en la carga inicial deja el estado en error, sin reintentos '
      'automáticos que gasten otra inferencia',
      () async {
        final repo = _FakeSummaryRepository(falla: true);
        final container = _container(repo: repo, persona: _personaAlicia);

        await expectLater(
          container.read(resumenInteligenteProvider.future),
          throwsA(isA<ServidorException>()),
        );
        expect(
          container.read(resumenInteligenteProvider),
          isA<AsyncError<ResumenInteligente?>>(),
        );
        expect(repo.llamadas, hasLength(1));
      },
    );

    test('una falla en refrescar() deja el estado en error', () async {
      final repo = _FakeSummaryRepository(falla: true);
      final container = _container(repo: repo, persona: _personaAlicia);
      await expectLater(
        container.read(resumenInteligenteProvider.future),
        throwsA(isA<ServidorException>()),
      );

      await container.read(resumenInteligenteProvider.notifier).refrescar();

      expect(repo.llamadas.last.forzarActualizacion, isTrue);
      expect(
        container.read(resumenInteligenteProvider),
        isA<AsyncError<ResumenInteligente?>>(),
      );
    });

    test('al cambiar la persona de contexto se vuelve a consultar', () async {
      final repo = _FakeSummaryRepository();
      // La persona de contexto se cambia mutando esta variable e invalidando
      // el provider que la expone, que es lo que observa el notifier.
      Persona? personaActual = _personaAlicia;

      final container = ProviderContainer(
        overrides: [
          personaVisualizacionSeleccionadaProvider.overrideWith(
            (ref) async => ref.watch(_personaTestProvider),
          ),
          _personaTestProvider.overrideWith((ref) => personaActual),
          summaryRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      container.listen(resumenInteligenteProvider, (_, _) {});

      await container.read(resumenInteligenteProvider.future);
      expect(repo.llamadas.single.personaId, 2);

      personaActual = _personaCarlos;
      container.invalidate(_personaTestProvider);
      await container.read(resumenInteligenteProvider.future);

      expect(repo.llamadas, hasLength(2));
      expect(repo.llamadas.last.personaId, 3);
      expect(repo.llamadas.last.forzarActualizacion, isFalse);
    });
  });
}

/// Fuente de la persona de contexto en el test de cambio de persona.
final _personaTestProvider = Provider<Persona?>((ref) => null);
