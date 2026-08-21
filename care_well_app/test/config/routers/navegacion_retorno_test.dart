import 'package:care_well_app/config/routers/app_router.dart';
import 'package:care_well_app/config/routers/app_routes.dart';
import 'package:care_well_app/config/theme/theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/domain/repositories/repositories.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../_fakes/test_fixtures.dart';

/// Regresión: volver de una acción no puede destruir el stack de navegación.
///
/// `context.go()` reemplaza el stack completo por el que corresponde a la URL
/// destino. Usarlo para "volver" borraba Home y dejaba pantallas sin flecha de
/// retroceso, donde el gesto de back cerraba la aplicación. Estos tests
/// recorren los flujos reales y verifican que después de la acción se pueda
/// seguir volviendo hasta Home.
final _usuario = Usuario(
  id: 101,
  persona: Persona(
    id: 1,
    nombre: 'María',
    apellido: 'García',
    documento: '30111222',
    fechaNacimiento: DateTime(1985, 3, 4),
  ),
  contrasena: 'hash123',
  estado: estadoUsuarioActivo,
);

final _alicia = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

final _hoy = DateTime.now();
final _inicioDeHoy = DateTime(_hoy.year, _hoy.month, _hoy.day);

final _miembroEquipo = AsignacionCuidado(
  id: 401,
  personaCuidada: _alicia,
  colaborador: _usuario.persona,
  rol: rolCuidadoResponsable,
  estado: estadoAsignacionActiva,
  fechaAlta: DateTime(2024, 1, 8),
);

final _evento = EventoSalud(
  id: 1101,
  persona: refPersonaAlicia,
  tipo: tipoEventoSaludCitaMedica,
  fechaHora: _inicioDeHoy,
  descripcion: 'Control cardiológico',
);

/// Resumen inteligente de la card hero del Home, sin pegarle a la API.
class _FakeSummaryRepository implements SummaryRepository {
  @override
  Future<ResumenInteligente> obtenerResumen({
    required int personaId,
    bool forzarActualizacion = false,
  }) async => ResumenInteligente(
    resumenAcotado: 'Jornada tranquila.',
    tieneDatos: true,
    generadoEn: _inicioDeHoy,
  );
}

/// Container con sesión iniciada y todas las fuentes de red sustituidas.
///
/// [eventoEliminado] refleja en la lista el efecto del borrado, igual que en
/// la app: el caso de uso invalida los providers de eventos al terminar.
ProviderContainer _container({
  bool Function()? eventoEliminado,
  void Function()? alEliminar,
}) {
  return ProviderContainer(
    overrides: [
      authStateProvider.overrideWith(
        (ref) =>
            AuthNotifier(ref.watch(authRepositoryProvider))
              ..state = AsyncValue.data(_usuario),
      ),
      // Persona de contexto y avatares (ContextAppBar / HomeHeader).
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _alicia,
      ),
      personaImagenProvider.overrideWith((ref, id) async => null),
      // Home.
      asignacionesActivasComoResponsableProvider.overrideWith(
        (ref) async => <AsignacionCuidado>[],
      ),
      asignacionesActivasComoCuidadorProvider.overrideWith(
        (ref) async => <AsignacionCuidado>[],
      ),
      animoHoyProvider.overrideWith((ref) async => null),
      summaryRepositoryProvider.overrideWithValue(_FakeSummaryRepository()),
      // Hub de Salud y eventos.
      puedeVerSaludProvider.overrideWith((ref) async => true),
      puedeRegistrarEventosSaludProvider.overrideWith((ref) async => true),
      resumenSaludProvider.overrideWith((ref) async => null),
      eventosSaludDeSemanaProvider.overrideWith(
        (ref) async =>
            (eventoEliminado?.call() ?? false) ? <EventoSalud>[] : [_evento],
      ),
      eventoSaludAnteriorProvider.overrideWith((ref) async => null),
      eliminarEventoSaludProvider.overrideWith((ref) {
        return ({required eventoId}) async {
          alEliminar?.call();
          ref.invalidate(eventosSaludDeSemanaProvider);
        };
      }),
      // Emergencia.
      equipoEmergenciaProvider.overrideWith((ref) async => [_miembroEquipo]),
      historialEmergenciasProvider.overrideWith((ref) async => <Emergencia>[]),
      puedeActivarEmergenciaProvider.overrideWith((ref) async => true),
      activarEmergenciaProvider.overrideWithValue(() async {}),
      // El AppShell resincroniza notificaciones al montarse.
      sincronizarNotificacionesAgendaProvider.overrideWithValue(
        ({required motivo}) async {},
      ),
    ],
  );
}

/// Página del fondo del stack del shell (la más vieja que sigue viva).
String _paginaDeFondo(GoRouter router) {
  final shell =
      router.routerDelegate.currentConfiguration.matches.first
          as ShellRouteMatch;
  final primera = shell.matches.first;
  return primera is ImperativeRouteMatch
      ? primera.matches.uri.toString()
      : (primera as RouteMatch).route.path;
}

/// Deja correr varios frames: resuelve los `FutureProvider` de cada pantalla y
/// completa las transiciones de página. No se usa `pumpAndSettle` porque los
/// skeletons de carga animan en loop y nunca dejarían el árbol quieto.
Future<void> _asentar(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

/// Monta la app real (router incluido) arrancando en Home.
Future<GoRouter> _montarEnHome(
  WidgetTester tester,
  ProviderContainer container,
) async {
  final router = container.read(goRouterProvider);
  router.go(AppRoutes.home);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme().light, routerConfig: router),
    ),
  );
  await _asentar(tester);
  return router;
}

void main() {
  setUpAll(() async => initializeDateFormatting('es'));

  group('Volver tras una acción conserva el stack', () {
    testWidgets('eliminar un evento de salud deja volver hasta Home', (
      tester,
    ) async {
      var eliminado = false;
      final container = _container(
        eventoEliminado: () => eliminado,
        alEliminar: () => eliminado = true,
      );
      addTearDown(container.dispose);
      final router = await _montarEnHome(tester, container);

      // Recorrido real del usuario: Home → Salud → Eventos → Detalle.
      router.pushNamed(AppRoutes.healthName);
      await _asentar(tester);
      router.pushNamed(AppRoutes.healthEventsName);
      await _asentar(tester);
      router.pushNamed(
        AppRoutes.healthEventDetailName,
        pathParameters: {'id': '${_evento.id}'},
      );
      await _asentar(tester);
      expect(find.byType(HealthEventDetailScreen), findsOneWidget);

      // Eliminar el evento y confirmar en el diálogo.
      await tester.tap(find.byTooltip('Eliminar evento'));
      await _asentar(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
      await _asentar(tester);

      // Se vuelve a la lista y el resto del stack sigue en pie.
      expect(find.byType(HealthEventsScreen), findsOneWidget);
      expect(_paginaDeFondo(router), AppRoutes.home);

      // Y desde ahí se sigue pudiendo volver: Eventos → Salud → Home.
      expect(find.byType(BackButton), findsOneWidget);
      await tester.tap(find.byType(BackButton));
      await _asentar(tester);
      expect(find.byType(HealthScreen), findsOneWidget);

      expect(
        find.byType(BackButton),
        findsOneWidget,
        reason:
            'Salud quedaba sin flecha de retroceso y el gesto de back cerraba '
            'la app',
      );
      await tester.tap(find.byType(BackButton));
      await _asentar(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('enviar una emergencia deja volver a Home sin reenviarla', (
      tester,
    ) async {
      final container = _container();
      addTearDown(container.dispose);
      final router = await _montarEnHome(tester, container);

      router.pushNamed(AppRoutes.emergencyName);
      await _asentar(tester);
      expect(find.byType(EmergencyScreen), findsOneWidget);

      // Activar la emergencia y confirmar.
      await tester.tap(find.byType(EmergencyButton));
      await _asentar(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Sí, enviar alerta'));
      await _asentar(tester);

      expect(find.byType(EmergencySentScreen), findsOneWidget);
      expect(_paginaDeFondo(router), AppRoutes.home);

      // "Volver al inicio" lleva a Home, y la pantalla del botón de
      // emergencia ya no está apilada (anti-reenvío).
      await tester.tap(find.widgetWithText(OutlinedButton, 'Volver al inicio'));
      await _asentar(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.byType(EmergencyScreen, skipOffstage: false),
        findsNothing,
        reason: 'No se puede volver al botón de emergencia con el back',
      );
    });
  });
}
