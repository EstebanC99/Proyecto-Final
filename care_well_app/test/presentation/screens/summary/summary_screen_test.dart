import 'dart:async';

import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/exceptions/exceptions.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _personaAlicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

/// Fake de [SummaryRepository] que devuelve un resumen fijo, falla o se queda
/// colgado, según cómo se lo construya.
///
/// Registra el flag de cada llamada para verificar qué disparadores fuerzan la
/// regeneración.
class _FakeSummaryRepository implements SummaryRepository {
  _FakeSummaryRepository.conResumen(this._resumen)
    : _falla = null,
      _colgado = false;
  _FakeSummaryRepository.queFalla()
    : _resumen = null,
      _falla = Exception('el servicio no respondió'),
      _colgado = false;
  _FakeSummaryRepository.queFallaCon(Object error)
    : _resumen = null,
      _falla = error,
      _colgado = false;
  _FakeSummaryRepository.queNuncaResponde()
    : _resumen = null,
      _falla = null,
      _colgado = true;

  final ResumenInteligente? _resumen;
  final Object? _falla;
  final bool _colgado;

  /// Flag recibido en cada invocación, en orden.
  final List<bool> forzados = [];

  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  }) {
    forzados.add(forzarActualizacion);
    if (_colgado) return Completer<ResumenInteligente>().future;
    if (_falla != null) return Future.error(_falla);
    return Future.value(_resumen!);
  }
}

Widget _wrap(SummaryRepository repositorio) {
  return ProviderScope(
    overrides: [
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _personaAlicia,
      ),
      personasSeleccionablesProvider.overrideWith(
        (ref) async => [
          PersonaContextOption(
            persona: _personaAlicia,
            rol: PersonaContextRol.responsable,
          ),
        ],
      ),
      summaryRepositoryProvider.overrideWithValue(repositorio),
    ],
    child: const MaterialApp(home: SummaryScreen()),
  );
}

const _resumenCompleto = ResumenInteligente(
  resumenAcotado: 'Jornada tranquila.',
  estadoAnimo: 'Alegre y con energía',
  resumenHabitos: 'Cumplió con casi toda la rutina.',
  habitos: [
    HabitoResumen(descripcion: 'Caminata matutina', completado: true),
    HabitoResumen(descripcion: 'Cena', completado: false),
  ],
  eventosSalud: [
    EventoSaludResumen(descripcion: 'Control de presión', hora: '08:45'),
  ],
  recomendaciones: ['Vigilá la digestión.'],
  recordatoriosHoy: ['Medicación de la noche'],
  recordatoriosManana: ['Turno con la kinesióloga'],
  habitosManana: [
    HabitoResumen(descripcion: 'Caminata matutina', completado: false),
  ],
  tieneDatos: true,
);

void main() {
  group('SummaryScreen', () {
    testWidgets('con las cuatro secciones pinta las cuatro cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(_FakeSummaryRepository.conResumen(_resumenCompleto)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hábitos de hoy'), findsOneWidget);
      expect(find.text('Salud'), findsOneWidget);
      expect(find.text('A tener en cuenta'), findsOneWidget);
      expect(find.text('Mañana'), findsOneWidget);
      expect(find.text('Alegre y con energía'), findsOneWidget);
      expect(find.byType(SummaryFooterDisclaimer), findsOneWidget);
      expect(find.byType(SummaryEmptyState), findsNothing);
    });

    testWidgets(
      'un resumen con solo resumenAcotado cae en el estado vacío: ese texto '
      'alimenta el hero del Home, no esta pantalla',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            _FakeSummaryRepository.conResumen(
              const ResumenInteligente(
                resumenAcotado: 'Jornada tranquila.',
                tieneDatos: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SummaryEmptyState), findsOneWidget);
        expect(find.byType(SummaryFooterDisclaimer), findsNothing);
      },
    );

    testWidgets('con comentario de hábitos y sin lista muestra la card', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          _FakeSummaryRepository.conResumen(
            const ResumenInteligente(
              resumenHabitos: 'Cumplió con casi toda la rutina.',
              tieneDatos: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hábitos de hoy'), findsOneWidget);
      expect(find.text('Cumplió con casi toda la rutina.'), findsOneWidget);
      expect(find.byType(HabitsProgressRing), findsNothing);
      expect(find.byType(SummaryEmptyState), findsNothing);
    });

    testWidgets('si el repositorio falla ofrece reintentar', (tester) async {
      await tester.pumpWidget(_wrap(_FakeSummaryRepository.queFalla()));
      await tester.pumpAndSettle();

      expect(find.byType(InlineErrorBanner), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('el banner de error no se estira a toda la pantalla', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_FakeSummaryRepository.queFalla()));
      await tester.pumpAndSettle();

      final alto = tester.getSize(find.byType(InlineErrorBanner)).height;
      final altoPantalla = tester.getSize(find.byType(SummaryScreen)).height;
      expect(alto, lessThan(altoPantalla / 2));
    });

    testWidgets('un error inesperado no vuelca el detalle técnico', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_FakeSummaryRepository.queFalla()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsNothing);
      expect(
        find.text(
          'No se pudo generar el resumen. Intentá de nuevo en unos '
          'minutos.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('una falla conocida muestra su propio mensaje', (tester) async {
      await tester.pumpWidget(
        _wrap(_FakeSummaryRepository.queFallaCon(const SinConexionException())),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Sin conexión. Verificá tu red e intentá de nuevo.'),
        findsOneWidget,
      );
    });

    testWidgets('la carga inicial no fuerza la regeneración', (tester) async {
      final repo = _FakeSummaryRepository.conResumen(_resumenCompleto);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      expect(repo.forzados, [false]);
    });

    testWidgets('el botón Actualizar fuerza la regeneración', (tester) async {
      final repo = _FakeSummaryRepository.conResumen(_resumenCompleto);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Actualizar'));
      await tester.pumpAndSettle();

      expect(repo.forzados, [false, true]);
    });

    testWidgets('el pull-to-refresh fuerza la regeneración', (tester) async {
      final repo = _FakeSummaryRepository.conResumen(_resumenCompleto);
      await tester.pumpWidget(_wrap(repo));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();

      expect(repo.forzados, [false, true]);
    });

    testWidgets(
      'con una generación en curso no se encadena un segundo pedido',
      (tester) async {
        final repo = _FakeSummaryRepository.queNuncaResponde();
        await tester.pumpWidget(_wrap(repo));
        await tester.pump();
        await tester.pump();

        // El botón queda deshabilitado mientras se genera.
        final boton = tester.widget<IconButton>(
          find.widgetWithIcon(IconButton, Icons.refresh),
        );
        expect(boton.onPressed, isNull);

        // Y el pull-to-refresh sólo espera a la generación en curso.
        await tester.fling(
          find.byType(SingleChildScrollView),
          const Offset(0, 400),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(repo.forzados, [false]);

        // El pedido nunca resuelve: se desmonta el árbol y se dejan correr los
        // temporizadores pendientes.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
      },
    );

    testWidgets('mientras se genera muestra el esqueleto', (tester) async {
      await tester.pumpWidget(_wrap(_FakeSummaryRepository.queNuncaResponde()));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SummaryLoadingSkeleton), findsOneWidget);

      // El pedido nunca resuelve: se desmonta el árbol y se dejan correr los
      // temporizadores pendientes (el pulso del esqueleto, el autoDispose del
      // provider) para que el test no termine con trabajo en vuelo.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
