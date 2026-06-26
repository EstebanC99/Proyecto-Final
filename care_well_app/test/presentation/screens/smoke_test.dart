import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => ProviderScope(child: MaterialApp(home: child));

/// HomeScreen necesita providers con datos resueltos para evitar el skeleton
/// (que tiene timers infinitos de shimmer) y para drenar las animaciones de
/// animate_do sin dejar timers pendientes.
Widget _wrapHome() {
  return ProviderScope(
    overrides: [
      // Sobreescribe assignmentsAsResponsableProvider con lista vacía resuelta para evitar
      // el NavTileSkeleton, que tiene un AnimationController de shimmer infinito.
      activeAssignmentsAsResponsableProvider.overrideWith(
        (ref) async => <AsignacionCuidado>[],
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

/// Drena las animaciones de entrada de animate_do (máx 400ms de delay + 400ms de duración).
Future<void> _drainAnimations(WidgetTester tester) async {
  await tester.pump(); // resuelve el FutureProvider
  await tester.pump(const Duration(milliseconds: 900));
}

void main() {
  group('Smoke — pantallas principales', () {
    testWidgets('LoginScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const LoginScreen()));
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('HomeScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrapHome());
      await _drainAnimations(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('ProfileScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const ProfileScreen()));
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('SettingsScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsScreen()));
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('DependentsScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const DependentsScreen()));
      expect(find.byType(DependentsScreen), findsOneWidget);
    });

    testWidgets('AgendaScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const AgendaScreen()));
      expect(find.byType(AgendaScreen), findsOneWidget);
    });

    testWidgets('HealthScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const HealthScreen()));
      expect(find.byType(HealthScreen), findsOneWidget);
    });

    testWidgets('EmergencyScreen monta sin errores', (tester) async {
      await tester.pumpWidget(_wrap(const EmergencyScreen()));
      // La pantalla carga providers de forma asíncrona y EmergencyButton usa
      // Pulse (animate_do) con un timer de animación. Drenamos para evitar
      // pending timers después del dispose.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2100));
      expect(find.byType(EmergencyScreen), findsOneWidget);
    });
  });
}
