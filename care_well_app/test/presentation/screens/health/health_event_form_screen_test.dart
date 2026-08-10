import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/health/health_event_form_screen.dart';
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
      tiposEventoProvider.overrideWith((ref) async => [_tipo]),
      crearEventoSaludProvider.overrideWithValue(crear ?? _crearNoop),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Monta el formulario como ruta apilada (para que el `pop` posterior al
/// guardado tenga a dónde volver).
Future<void> _pushForm(WidgetTester tester, ProviderContainer container) async {
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
    MaterialPageRoute(builder: (_) => const HealthEventFormScreen()),
  );
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

void main() {
  group('HealthEventFormScreen', () {
    testWidgets('al registrar un evento se salta a su día y semana', (
      tester,
    ) async {
      final container = _container();

      // La pantalla de eventos está mirando una semana lejana.
      container.read(semanaEventosSaludProvider.notifier).state = _lunesLejano;
      container.read(diaEventosSaludSeleccionadoProvider.notifier).state =
          _lunesLejano;

      await _pushForm(tester, container);
      // El formulario arranca con la fecha de hoy.
      await _registrar(tester, 'Control de presión');

      expect(container.read(diaEventosSaludSeleccionadoProvider), _hoy);
      expect(container.read(semanaEventosSaludProvider), _lunesDeEstaSemana);
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

      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();

      // El calendario no ofrece fechas posteriores a hoy: el salto que hace el
      // formulario al guardar nunca puede apuntar a un día futuro.
      final picker = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(_soloFecha(picker.lastDate), _hoy);
    });
  });
}
