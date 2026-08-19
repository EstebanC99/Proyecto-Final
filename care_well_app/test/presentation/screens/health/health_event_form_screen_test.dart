import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/health/health_event_form_screen.dart';
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

/// Catálogo completo de 13 tipos, en orden invertido: la pantalla lo ordena
/// por id para que "Otro" quede último.
final _tipos = [
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

DateTime _soloFecha(DateTime f) => DateTime(f.year, f.month, f.day);

final _hoy = _soloFecha(DateTime.now());
final _lunesDeEstaSemana = _hoy.subtract(Duration(days: _hoy.weekday - 1));

/// Lunes de una semana lejana, usada como estado inicial de la pantalla para
/// comprobar que al registrar se salta a la semana del evento.
final _lunesLejano = _lunesDeEstaSemana.subtract(const Duration(days: 42));

// ─── Helpers ──────────────────────────────────────────────────────────────────

/// No-op con la firma de [crearEventoSaludProvider].
Future<void> _crearNoop({
  required int tipoId,
  required String descripcion,
  required DateTime fechaHora,
}) async {}

ProviderContainer _container({
  Future<void> Function({
    required int tipoId,
    required String descripcion,
    required DateTime fechaHora,
  })?
  crear,
}) {
  final container = ProviderContainer(
    overrides: [
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
      tiposEventoProvider.overrideWith((ref) async => _tipos),
      crearEventoSaludProvider.overrideWithValue(crear ?? _crearNoop),
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
    MaterialPageRoute(builder: (_) => const HealthEventFormScreen()),
  );
  await tester.pumpAndSettle();
}

/// Abre el selector de fecha. La grilla de 13 tipos empuja el par fecha/hora
/// fuera de la pantalla, así que primero hay que traerlo a la vista.
Future<void> _abrirSelectorFecha(WidgetTester tester) async {
  await tester.ensureVisible(find.byIcon(Icons.calendar_today_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.calendar_today_outlined));
  await tester.pumpAndSettle();
}

/// Trae [finder] a la vista y lo toca.
///
/// La grilla de 13 tipos hace que los tiles del fondo queden fuera de la
/// pantalla: sin el scroll previo el toque cae en cualquier otro lado.
Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Una hora de HOY que todavía no pasó, para probar el recorte de futuro.
///
/// Se calcula desde el reloj en vez de fijarse (un `23:59` literal deja de ser
/// futuro a las 23:59). Devuelve `null` en los últimos minutos del día, donde
/// el escenario no existe.
TimeOfDay? _horaFuturaDeHoy() {
  final ahora = DateTime.now();
  final objetivo = ahora.add(const Duration(minutes: 5));
  if (objetivo.day != ahora.day) return null;
  return TimeOfDay.fromDateTime(objetivo);
}

/// Elige [hora] en el selector de hora.
///
/// El diálogo arranca en modo reloj, imposible de manejar desde un test: se lo
/// pasa al modo "escribir" con el botón del teclado y se tipean los valores.
Future<void> _elegirHora(WidgetTester tester, TimeOfDay hora) async {
  await tester.ensureVisible(find.byIcon(Icons.schedule_outlined));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.schedule_outlined));
  await tester.pumpAndSettle();

  await tester.tap(
    find
        .descendant(
          of: find.byType(TimePickerDialog),
          matching: find.byType(IconButton),
        )
        .first,
  );
  await tester.pumpAndSettle();

  final campos = find.descendant(
    of: find.byType(TimePickerDialog),
    matching: find.byType(TextField),
  );
  final hora12 = hora.hourOfPeriod == 0 ? 12 : hora.hourOfPeriod;
  await tester.enterText(campos.at(0), '$hora12');
  await tester.enterText(campos.at(1), hora.minute.toString().padLeft(2, '0'));
  await tester.tap(find.text(hora.period == DayPeriod.am ? 'AM' : 'PM'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

/// Completa la descripción y toca "Registrar evento" (al final del scroll).
Future<void> _registrar(WidgetTester tester, String descripcion) async {
  await tester.enterText(find.byType(TextFormField).first, descripcion);
  await tester.pump();
  await tester.ensureVisible(find.text('Registrar evento'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Registrar evento'));
  await tester.pumpAndSettle();
}

/// Dispara el gesto de "atrás" del sistema.
Future<void> _volverAtras(WidgetTester tester) async {
  final dynamic estado = tester.state(find.byType(WidgetsApp));
  await estado.didPopRoute();
  await tester.pumpAndSettle();
}

void main() {
  group('HealthEventFormScreen', () {
    testWidgets('al registrar un evento se salta a su día y semana', (
      tester,
    ) async {
      final container = _container();

      // La pantalla de eventos está mirando el día de hoy, pero con la semana
      // desincronizada (estado que deja un salto previo): al registrar, la
      // semana debe recalcularse a partir de la fecha del evento.
      container.read(semanaEventosSaludProvider.notifier).state = _lunesLejano;
      container.read(diaEventosSaludSeleccionadoProvider.notifier).state = _hoy;

      await _pushForm(tester, container);
      await _registrar(tester, 'Control de presión');

      expect(container.read(diaEventosSaludSeleccionadoProvider), _hoy);
      expect(container.read(semanaEventosSaludProvider), _lunesDeEstaSemana);
    });

    // El alta debe ofrecer el día que el usuario está mirando en la tira; con
    // la fecha de hoy fija resultaba engañoso. Acá se verifica sobre el payload
    // que se manda a crear, no sólo sobre el texto en pantalla.
    testWidgets('el alta arranca en el día seleccionado, no en hoy', (
      tester,
    ) async {
      DateTime? fechaEnviada;
      final container = _container(
        crear:
            ({
              required tipoId,
              required descripcion,
              required fechaHora,
            }) async {
              fechaEnviada = fechaHora;
            },
      );

      final diaPasado = _hoy.subtract(const Duration(days: 5));
      container.read(diaEventosSaludSeleccionadoProvider.notifier).state =
          diaPasado;
      container.read(semanaEventosSaludProvider.notifier).state = diaPasado
          .subtract(Duration(days: diaPasado.weekday - 1));

      await _pushForm(tester, container);

      // Lo que se ve en el formulario…
      expect(find.text(fechaCortaRelativa(diaPasado)), findsOneWidget);

      // …y lo que efectivamente se registra.
      await _registrar(tester, 'Control de presión');
      expect(_soloFecha(fechaEnviada!), diaPasado);
    });

    testWidgets('no mueve la pantalla si el registro falla', (tester) async {
      final container = _container(
        crear:
            ({
              required tipoId,
              required descripcion,
              required fechaHora,
            }) async => throw Exception('sin conexión'),
      );

      container.read(semanaEventosSaludProvider.notifier).state = _lunesLejano;
      container.read(diaEventosSaludSeleccionadoProvider.notifier).state =
          _lunesLejano;

      await _pushForm(tester, container);
      await _registrar(tester, 'Control de presión');

      expect(container.read(diaEventosSaludSeleccionadoProvider), _lunesLejano);
      expect(container.read(semanaEventosSaludProvider), _lunesLejano);
    });

    testWidgets('el selector de fecha no permite elegir días futuros', (
      tester,
    ) async {
      final container = _container();
      await _pushForm(tester, container);

      await _abrirSelectorFecha(tester);

      // El calendario no ofrece fechas posteriores a hoy: el salto que hace el
      // formulario al guardar nunca puede apuntar a un día futuro.
      final picker = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(_soloFecha(picker.lastDate), _hoy);
    });

    // ─── Rediseño visual (fase 2) ───────────────────────────────────────────

    testWidgets('muestra el rótulo del modo y a la persona de contexto', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      expect(find.byType(ContextAppBar), findsOneWidget);
      expect(find.text('NUEVO EVENTO DE SALUD'), findsOneWidget);
      expect(find.text('Alicia Rodríguez'), findsOneWidget);
      // Sin chevron en la barra: no se puede cambiar de persona a mitad de la
      // carga. El finder se acota al AppBar porque las píldoras de fecha y
      // hora usan el mismo ícono como caret.
      expect(
        find.descendant(
          of: find.byType(ContextAppBar),
          matching: find.byIcon(Icons.expand_more),
        ),
        findsNothing,
      );
    });

    testWidgets('con 13 tipos muestra 5 tiles y el botón "Ver más"', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      expect(find.byType(TypeTileGrid), findsOneWidget);
      expect(find.text('Ver más'), findsOneWidget);

      // Los 5 primeros por id; el sexto ya queda detrás de "Ver más".
      expect(find.text('Cita médica'), findsOneWidget);
      expect(find.text('Hospitalización'), findsOneWidget);
      expect(find.text('Cirugía'), findsNothing);
      expect(find.text('Otro'), findsNothing);
    });

    testWidgets('"Ver más" despliega los 13 tipos y "Ver menos" colapsa', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      await _tocar(tester, find.text('Ver más'));

      expect(find.text('Otro'), findsOneWidget);
      expect(find.text('Ver menos'), findsOneWidget);

      await _tocar(tester, find.text('Ver menos'));

      expect(find.text('Otro'), findsNothing);
      expect(find.text('Ver más'), findsOneWidget);
    });

    testWidgets('la selección hecha en la parte oculta sobrevive al colapso', (
      tester,
    ) async {
      int? tipoEnviado;
      final container = _container(
        crear:
            ({
              required tipoId,
              required descripcion,
              required fechaHora,
            }) async {
              tipoEnviado = tipoId;
            },
      );
      await _pushForm(tester, container);

      await _tocar(tester, find.text('Ver más'));
      await _tocar(tester, find.text('Vacuna'));
      await _tocar(tester, find.text('Ver menos'));

      // El tile elegido ya no se ve, pero la selección sigue en pie.
      expect(find.text('Vacuna'), findsNothing);
      final grilla = tester.widget<TypeTileGrid>(find.byType(TypeTileGrid));
      expect(grilla.selectedId, TiposEventoAgendaConst.vacuna);

      await _registrar(tester, 'Antigripal');
      expect(tipoEnviado, TiposEventoAgendaConst.vacuna);
    });

    testWidgets('tocar un tile cambia el tipo que se registra', (tester) async {
      int? tipoEnviado;
      final container = _container(
        crear:
            ({
              required tipoId,
              required descripcion,
              required fechaHora,
            }) async {
              tipoEnviado = tipoId;
            },
      );
      await _pushForm(tester, container);

      await tester.tap(find.text('Medicación'));
      await tester.pumpAndSettle();
      await _registrar(tester, 'Tomó el antihipertensivo');

      expect(tipoEnviado, TiposEventoAgendaConst.medicacion);
    });

    testWidgets('la fecha se muestra en formato relativo', (tester) async {
      final container = _container();
      container.read(diaEventosSaludSeleccionadoProvider.notifier).state = _hoy;

      await _pushForm(tester, container);

      expect(find.text(fechaCortaRelativa(_hoy)), findsOneWidget);
      expect(find.textContaining('Hoy'), findsOneWidget);
    });

    testWidgets('el CTA se habilita recién cuando hay descripción', (
      tester,
    ) async {
      await _pushForm(tester, _container());

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        find.text('Completá la descripción para continuar'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextFormField), 'Control de presión');
      await tester.pumpAndSettle();

      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
      expect(find.text('Completá la descripción para continuar'), findsNothing);
    });

    testWidgets('una hora futura se recorta al presente y se avisa', (
      tester,
    ) async {
      DateTime? enviada;
      final container = _container(
        crear:
            ({
              required tipoId,
              required descripcion,
              required fechaHora,
            }) async {
              enviada = fechaHora;
            },
      );
      container.read(diaEventosSaludSeleccionadoProvider.notifier).state = _hoy;
      await _pushForm(tester, container);

      final futura = _horaFuturaDeHoy();
      if (futura == null) return; // últimos minutos del día
      await _elegirHora(tester, futura);

      // El recorte deja de ser silencioso: antes se elegían las 23:59, se
      // guardaba la hora actual y nadie se lo decía al usuario.
      expect(
        find.text(
          'Un evento de salud no puede ser futuro; se ajustó a la hora actual.',
        ),
        findsOneWidget,
      );

      await _registrar(tester, 'Control de presión');
      expect(enviada, isNotNull);
      expect(enviada!.isAfter(DateTime.now()), isFalse);
    });

    testWidgets('en un día pasado se respeta cualquier hora', (tester) async {
      DateTime? enviada;
      final container = _container(
        crear:
            ({
              required tipoId,
              required descripcion,
              required fechaHora,
            }) async {
              enviada = fechaHora;
            },
      );
      container.read(diaEventosSaludSeleccionadoProvider.notifier).state = _hoy
          .subtract(const Duration(days: 3));
      await _pushForm(tester, container);

      await _elegirHora(tester, const TimeOfDay(hour: 23, minute: 30));

      expect(
        find.text(
          'Un evento de salud no puede ser futuro; se ajustó a la hora actual.',
        ),
        findsNothing,
      );

      await _registrar(tester, 'Control de presión');
      expect(enviada!.hour, 23);
      expect(enviada!.minute, 30);
    });

    testWidgets('mover la fecha a hoy también recorta una hora tardía', (
      tester,
    ) async {
      // El agujero que tapa esta prueba: la hora se validaba sólo al elegirla,
      // así que 23:30 de ayer seguía siendo 23:30 al mover la fecha a hoy.
      if (_hoy.day < 2) return; // el calendario no muestra el mes anterior

      DateTime? enviada;
      final container = _container(
        crear:
            ({
              required tipoId,
              required descripcion,
              required fechaHora,
            }) async {
              enviada = fechaHora;
            },
      );
      final ayer = _hoy.subtract(const Duration(days: 1));
      container.read(diaEventosSaludSeleccionadoProvider.notifier).state = ayer;
      await _pushForm(tester, container);

      // Una hora que hoy sería futura, pero en un día pasado es válida.
      final futura = _horaFuturaDeHoy();
      if (futura == null) return; // últimos minutos del día
      await _elegirHora(tester, futura);
      expect(find.textContaining('no puede ser futuro'), findsNothing);

      // Ahora se mueve la fecha a hoy: la combinación pasa a ser futura.
      await _abrirSelectorFecha(tester);
      await tester.tap(
        find
            .descendant(
              of: find.byType(DatePickerDialog),
              matching: find.text('${_hoy.day}'),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.textContaining('no puede ser futuro'), findsOneWidget);

      await _registrar(tester, 'Control de presión');
      expect(enviada!.isAfter(DateTime.now()), isFalse);
    });
  });

  group('HealthEventFormScreen · robustez de layout', () {
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
          _container(),
          textScaler: const TextScaler.linear(1.6),
          themeMode: themeMode,
        );

        expect(tester.takeException(), isNull);

        // Expandir la grilla es el peor caso: 13 tiles a doble columna.
        await tester.tap(find.text('Ver más'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Y el par fecha/hora, que es donde el texto puede desbordar.
        await tester.ensureVisible(find.byIcon(Icons.schedule_outlined));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('HealthEventFormScreen · cambios sin guardar', () {
    testWidgets('sin tocar nada el atrás cierra directo', (tester) async {
      await _pushForm(tester, _container());

      await _volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsNothing);
    });

    testWidgets('con descripción escrita el atrás pregunta', (tester) async {
      await _pushForm(tester, _container());

      await tester.enterText(find.byType(TextFormField), 'Control de presión');
      await tester.pumpAndSettle();
      await _volverAtras(tester);

      expect(find.text('Tenés cambios sin guardar'), findsOneWidget);
    });
  });
}
