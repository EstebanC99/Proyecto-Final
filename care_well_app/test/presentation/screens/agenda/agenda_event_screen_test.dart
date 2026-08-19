import 'dart:async';

import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/agenda/agenda_event_screen.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

final _persona = Persona(
  id: 12,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _tipo = TipoEvento(id: 1, descripcion: 'Cita Médica');

DateTime _soloFecha(DateTime f) => DateTime(f.year, f.month, f.day);

final _hoy = _soloFecha(DateTime.now());
final _lunesDeEstaSemana = _hoy.subtract(Duration(days: _hoy.weekday - 1));

/// Lunes de una semana lejana, usada como estado inicial de la agenda para
/// comprobar que al guardar se salta a la semana del evento.
final _lunesLejano = _lunesDeEstaSemana.subtract(const Duration(days: 42));

OcurrenciaEventoAgenda _ocurrencia(DateTime inicio) => OcurrenciaEventoAgenda(
  id: 7,
  eventoAgendaId: 7,
  personaId: _persona.id,
  titulo: 'Control cardiológico',
  tipo: _tipo,
  fechaHoraInicio: inicio,
  fechaHoraFin: inicio.add(const Duration(hours: 1)),
  esRecurrente: false,
  generarEventoSalud: false,
);

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// No-op con la firma de [crearEventoAgendaProvider].
Future<void> _crearNoop({
  required int personaId,
  required String titulo,
  String? descripcion,
  required int tipoEventoId,
  required DateTime fechaHoraInicio,
  required int duracionMinutos,
  required bool generarEventoSalud,
  int? minutosAnticipacionRecordatorio,
  int? frecuenciaRecurrenciaId,
  int? intervaloRecurrencia,
  DateTime? fechaFinRecurrencia,
}) async {}

/// No-op con la firma de [modificarEventoAgendaProvider].
Future<void> _modificarNoop({
  required int eventoAgendaId,
  required String titulo,
  String? descripcion,
  required int tipoEventoId,
  required DateTime fechaHoraInicio,
  required int duracionMinutos,
  required bool generarEventoSalud,
  int? minutosAnticipacionRecordatorio,
}) async {}

/// Catálogo grande (los 13 tipos), en orden invertido: la pantalla lo ordena
/// por id para que "Otro" quede último.
final _tiposCompletos = [
  for (final (id, descripcion) in const [
    (TiposEventoAgendaConst.citaMedica, 'Cita médica'),
    (TiposEventoAgendaConst.medicacion, 'Medicación'),
    (TiposEventoAgendaConst.rehabilitacion, 'Rehabilitación'),
    (TiposEventoAgendaConst.control, 'Control'),
    (TiposEventoAgendaConst.hospitalizacion, 'Hospitalización'),
    (TiposEventoAgendaConst.cirugia, 'Cirugía'),
    (TiposEventoAgendaConst.tratamiento, 'Tratamiento'),
    (TiposEventoAgendaConst.bienestar, 'Bienestar'),
    (TiposEventoAgendaConst.sintoma, 'Síntoma'),
    (TiposEventoAgendaConst.diagnostico, 'Diagnóstico'),
    (TiposEventoAgendaConst.vacuna, 'Vacuna'),
    (TiposEventoAgendaConst.actividadFisica, 'Actividad física'),
    (TiposEventoAgendaConst.otro, 'Otro'),
  ].reversed)
    TipoEvento(id: id, descripcion: descripcion),
];

/// Catálogo chico: entra entero en la grilla, sin "Ver más".
final _tiposPocos = _tiposCompletos
    .where((t) => t.id <= TiposEventoAgendaConst.control)
    .toList();

ProviderContainer _container({
  List<OcurrenciaEventoAgenda> ocurrencias = const [],
  List<TipoEvento>? tipos,
  Future<List<OcurrenciaEventoAgenda>> Function()? ocurrenciasAsync,
  Future<void> Function({
    required int personaId,
    required String titulo,
    String? descripcion,
    required int tipoEventoId,
    required DateTime fechaHoraInicio,
    required int duracionMinutos,
    required bool generarEventoSalud,
    int? minutosAnticipacionRecordatorio,
    int? frecuenciaRecurrenciaId,
    int? intervaloRecurrencia,
    DateTime? fechaFinRecurrencia,
  })?
  crear,
}) {
  final container = ProviderContainer(
    overrides: [
      agendaPersonaContextProvider.overrideWith((ref) async => _persona),
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _persona,
      ),
      personasSeleccionablesProvider.overrideWith(
        (ref) async => [
          PersonaContextOption(
            persona: _persona,
            rol: PersonaContextRol.responsable,
          ),
        ],
      ),
      personaImagenProvider.overrideWith((ref, id) async => null),
      tiposEventoAgendablesProvider.overrideWith(
        (ref) async => tipos ?? [_tipo],
      ),
      ocurrenciasDeSemanaProvider.overrideWith(
        (ref) async =>
            ocurrenciasAsync != null ? await ocurrenciasAsync() : ocurrencias,
      ),
      crearEventoAgendaProvider.overrideWithValue(crear ?? _crearNoop),
      modificarEventoAgendaProvider.overrideWithValue(_modificarNoop),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Monta el formulario como ruta apilada (para que el `pop` posterior al
/// guardado tenga a dónde volver).
Future<void> _pushForm(
  WidgetTester tester,
  ProviderContainer container, {
  int? eventId,
  TextScaler textScaler = TextScaler.noScaling,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  final navKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        navigatorKey: navKey,
        themeMode: themeMode,
        theme: AppTheme().light,
        darkTheme: AppTheme().dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const Scaffold(body: SizedBox.shrink()),
      ),
    ),
  );
  navKey.currentState!.push(
    MaterialPageRoute(builder: (_) => AgendaEventScreen(eventId: eventId)),
  );
  await tester.pumpAndSettle();
}

/// Trae [finder] a la vista y lo toca.
///
/// El formulario es largo: sin el scroll previo el toque cae en cualquier otro
/// lado y Flutter sólo avisa con un warning.
Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Toca el botón de guardado, que vive al final del formulario scrolleable.
Future<void> _tapGuardar(WidgetTester tester, String label) async {
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void main() {
  group('AgendaEventScreen', () {
    testWidgets('al crear un evento la agenda salta a su día y semana', (
      tester,
    ) async {
      final container = _container();

      // La agenda está mirando una semana lejana.
      container.read(semanaSeleccionadaProvider.notifier).state = _lunesLejano;
      container.read(diaSeleccionadoProvider.notifier).state = _lunesLejano;

      await _pushForm(tester, container);

      // El día seleccionado es pasado, así que el alta cae en hoy.
      await tester.enterText(
        find.byType(TextFormField).first,
        'Control cardiológico',
      );
      await tester.pump();
      await _tapGuardar(tester, 'Crear evento');

      expect(container.read(diaSeleccionadoProvider), _hoy);
      expect(container.read(semanaSeleccionadaProvider), _lunesDeEstaSemana);
    });

    // El alta debe ofrecer el día que el usuario está mirando en la tira; con
    // la fecha de hoy fija resultaba engañoso.
    group('fecha inicial del alta', () {
      // El formulario muestra la fecha en formato relativo ("Hoy, 18 ago").
      String fechaVisible(DateTime f) => fechaCortaRelativa(f);

      testWidgets('toma el día seleccionado cuando es futuro', (tester) async {
        final enDiezDias = _hoy.add(const Duration(days: 10));
        final container = _container();
        container.read(diaSeleccionadoProvider.notifier).state = enDiezDias;
        container.read(semanaSeleccionadaProvider.notifier).state =
            lunesDeLaSemana(enDiezDias);

        await _pushForm(tester, container);

        expect(find.text(fechaVisible(enDiezDias)), findsOneWidget);
      });

      // La agenda no admite eventos pasados: parado en una semana anterior, el
      // alta cae en hoy en lugar de proponer una fecha inválida.
      testWidgets('cae en hoy cuando el día seleccionado es pasado', (
        tester,
      ) async {
        final container = _container();
        container.read(diaSeleccionadoProvider.notifier).state = _lunesLejano;
        container.read(semanaSeleccionadaProvider.notifier).state =
            _lunesLejano;

        await _pushForm(tester, container);

        expect(find.text(fechaVisible(_hoy)), findsOneWidget);
        expect(find.text(fechaVisible(_lunesLejano)), findsNothing);
      });
    });

    testWidgets('al editar un evento se salta al día que tiene cargado', (
      tester,
    ) async {
      // El evento a editar es de otra semana (dentro de 10 días).
      final fechaEvento = _hoy.add(const Duration(days: 10, hours: 9));
      final container = _container(ocurrencias: [_ocurrencia(fechaEvento)]);

      container.read(semanaSeleccionadaProvider.notifier).state =
          _lunesDeEstaSemana;
      container.read(diaSeleccionadoProvider.notifier).state = _hoy;

      await _pushForm(tester, container, eventId: 7);

      // El formulario precargó el evento: se guarda sin tocar la fecha.
      expect(find.text('Guardar cambios'), findsOneWidget);
      await _tapGuardar(tester, 'Guardar cambios');

      expect(container.read(diaSeleccionadoProvider), _soloFecha(fechaEvento));
      expect(
        container.read(semanaSeleccionadaProvider),
        lunesDeLaSemana(fechaEvento),
      );
    });

    testWidgets('no mueve la agenda si el guardado falla', (tester) async {
      final container = ProviderContainer(
        overrides: [
          agendaPersonaContextProvider.overrideWith((ref) async => _persona),
          personaVisualizacionSeleccionadaProvider.overrideWith(
            (ref) async => _persona,
          ),
          tiposEventoAgendablesProvider.overrideWith((ref) async => [_tipo]),
          ocurrenciasDeSemanaProvider.overrideWith((ref) async => const []),
          crearEventoAgendaProvider.overrideWithValue(({
            required personaId,
            required titulo,
            descripcion,
            required tipoEventoId,
            required fechaHoraInicio,
            required duracionMinutos,
            required generarEventoSalud,
            minutosAnticipacionRecordatorio,
            frecuenciaRecurrenciaId,
            intervaloRecurrencia,
            fechaFinRecurrencia,
          }) async {
            throw Exception('sin conexión');
          }),
        ],
      );
      addTearDown(container.dispose);

      container.read(semanaSeleccionadaProvider.notifier).state = _lunesLejano;
      container.read(diaSeleccionadoProvider.notifier).state = _lunesLejano;

      await _pushForm(tester, container);

      await tester.enterText(find.byType(TextFormField).first, 'Control');
      await tester.pump();
      await _tapGuardar(tester, 'Crear evento');

      expect(container.read(diaSeleccionadoProvider), _lunesLejano);
      expect(container.read(semanaSeleccionadaProvider), _lunesLejano);
    });

    // ─── Rediseño visual (fase 3) ───────────────────────────────────────────

    testWidgets('muestra el rótulo del modo y a la persona de contexto', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      expect(find.byType(ContextAppBar), findsOneWidget);
      expect(find.text('NUEVO EVENTO'), findsOneWidget);
      expect(find.text('Alicia Rodríguez'), findsOneWidget);
      // Sin chevron en la barra: el finder se acota al AppBar porque las
      // píldoras de fecha y hora usan el mismo ícono como caret.
      expect(
        find.descendant(
          of: find.byType(ContextAppBar),
          matching: find.byIcon(Icons.expand_more),
        ),
        findsNothing,
      );
    });

    testWidgets('con catálogo chico no dibuja "Ver más"', (tester) async {
      await _pushForm(tester, _container(tipos: _tiposPocos));

      expect(find.byType(TypeTileGrid), findsOneWidget);
      expect(find.text('Ver más'), findsNothing);
      for (final tipo in _tiposPocos) {
        expect(find.text(tipo.descripcion), findsOneWidget);
      }
    });

    testWidgets('con catálogo grande colapsa detrás de "Ver más"', (
      tester,
    ) async {
      await _pushForm(tester, _container(tipos: _tiposCompletos));

      expect(find.text('Ver más'), findsOneWidget);
      expect(find.text('Otro'), findsNothing);

      await _tocar(tester, find.text('Ver más'));
      expect(find.text('Otro'), findsOneWidget);
    });

    testWidgets('tocar un tile cambia el tipo que se guarda', (tester) async {
      int? tipoEnviado;
      final container = _container(
        tipos: _tiposCompletos,
        crear:
            ({
              required personaId,
              required titulo,
              descripcion,
              required tipoEventoId,
              required fechaHoraInicio,
              required duracionMinutos,
              required generarEventoSalud,
              minutosAnticipacionRecordatorio,
              frecuenciaRecurrenciaId,
              intervaloRecurrencia,
              fechaFinRecurrencia,
            }) async {
              tipoEnviado = tipoEventoId;
            },
      );
      await _pushForm(tester, container);

      await _tocar(tester, find.text('Medicación'));
      await tester.enterText(
        find.byType(TextFormField).first,
        'Antihipertensivo',
      );
      await tester.pump();
      await _tapGuardar(tester, 'Crear evento');

      expect(tipoEnviado, TiposEventoAgendaConst.medicacion);
    });

    testWidgets('en edición no parpadea la selección de tipo', (tester) async {
      // Las ocurrencias resuelven después que el catálogo: sin el flag de
      // precarga intentada, el primer frame pinta el tile 1 y la selección
      // salta cuando llega el evento.
      final precarga = Completer<List<OcurrenciaEventoAgenda>>();
      final container = _container(
        tipos: _tiposCompletos,
        ocurrenciasAsync: () => precarga.future,
      );

      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: navKey,
            home: const Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );
      navKey.currentState!.push(
        MaterialPageRoute(builder: (_) => const AgendaEventScreen(eventId: 7)),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byType(TypeTileGrid), findsOneWidget);
      expect(
        tester.widget<TypeTileGrid>(find.byType(TypeTileGrid)).selectedId,
        isNull,
      );

      precarga.complete([_ocurrencia(_hoy.add(const Duration(days: 2)))]);
      await tester.pumpAndSettle();

      expect(
        tester.widget<TypeTileGrid>(find.byType(TypeTileGrid)).selectedId,
        _tipo.id,
      );
    });

    testWidgets('si la ocurrencia no aparece igual cae al primer tipo', (
      tester,
    ) async {
      // Evento de otra semana o lista vacía: sin fallback el formulario se
      // quedaría sin tipo y con el guardar bloqueado para siempre.
      await _pushForm(tester, _container(tipos: _tiposCompletos), eventId: 999);

      expect(
        tester.widget<TypeTileGrid>(find.byType(TypeTileGrid)).selectedId,
        TiposEventoAgendaConst.citaMedica,
      );
    });

    testWidgets(
      'en edición abre la grilla si el tipo está detrás de "Ver más"',
      (tester) async {
        final ocu = OcurrenciaEventoAgenda(
          id: 7,
          eventoAgendaId: 7,
          personaId: _persona.id,
          titulo: 'Vacunación antigripal',
          tipo: TipoEvento(
            id: TiposEventoAgendaConst.vacuna,
            descripcion: 'Vacuna',
          ),
          fechaHoraInicio: _hoy.add(const Duration(days: 2)),
          fechaHoraFin: _hoy.add(const Duration(days: 2, hours: 1)),
          esRecurrente: false,
          generarEventoSalud: false,
        );

        await _pushForm(
          tester,
          _container(tipos: _tiposCompletos, ocurrencias: [ocu]),
          eventId: 7,
        );

        // El tipo 11 cae en la parte oculta: la grilla se abre sola.
        expect(find.text('Vacuna'), findsOneWidget);
        expect(find.text('Ver menos'), findsOneWidget);
      },
    );

    testWidgets('el CTA se habilita recién cuando hay título', (tester) async {
      await _pushForm(tester, _container());

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(find.text('Completá el título para continuar'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'Control');
      await tester.pumpAndSettle();

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      expect(find.text('Completá el título para continuar'), findsNothing);
    });

    testWidgets('el alta ofrece configurar la recurrencia', (tester) async {
      await _pushForm(tester, _container());

      expect(find.text('SE REPITE DE MANERA'), findsOneWidget);
    });

    testWidgets('la edición no ofrece configurar la recurrencia', (
      tester,
    ) async {
      await _pushForm(
        tester,
        _container(
          ocurrencias: [_ocurrencia(_hoy.add(const Duration(days: 2)))],
        ),
        eventId: 7,
      );

      expect(find.text('SE REPITE DE MANERA'), findsNothing);
    });
  });

  group('AgendaEventScreen · robustez de layout', () {
    for (final (nombre, themeMode) in [
      ('claro', ThemeMode.light),
      ('oscuro', ThemeMode.dark),
    ]) {
      testWidgets('sin overflow en tema $nombre con textScaler 1.6', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(360 * 3, 640 * 3);
        tester.view.devicePixelRatio = 3;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await _pushForm(
          tester,
          _container(tipos: _tiposCompletos),
          textScaler: const TextScaler.linear(1.6),
          themeMode: themeMode,
        );
        expect(tester.takeException(), isNull);

        await _tocar(tester, find.text('Ver más'));
        expect(tester.takeException(), isNull);

        // Recurrencia desplegada: el Row del intervalo (rótulo + stepper +
        // unidad) es el bloque con más elementos en fila de la pantalla.
        await _tocar(
          tester,
          find
              .descendant(
                of: find.ancestor(
                  of: find.text('Nunca'),
                  matching: find.byType(Row),
                ),
                matching: find.byIcon(Icons.chevron_right_rounded),
              )
              .first,
        );
        expect(find.text('Diaria'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}
