import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {TextScaler? textScaler}) => MaterialApp(
  theme: AppTheme().light,
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: textScaler ?? TextScaler.noScaling),
      child: Scaffold(body: child),
    ),
  ),
);

void main() {
  group('StatsPerfilCard', () {
    testWidgets('con datos muestra las tres cifras', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatsPerfilCard(
            stats: AsyncValue.data(
              StatsPerfil(aCargo: 2, colaboro: 3, edad: 40),
            ),
          ),
        ),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
    });

    testWidgets('muestra los rótulos literales', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatsPerfilCard(
            stats: AsyncValue.data(
              StatsPerfil(aCargo: 0, colaboro: 0, edad: 30),
            ),
          ),
        ),
      );

      expect(find.text('A cargo'), findsOneWidget);
      expect(find.text('Colaboro'), findsOneWidget);
      expect(find.text('Años'), findsOneWidget);
    });

    testWidgets('en carga la tarjeta sigue presente con tres guiones', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const StatsPerfilCard(stats: AsyncValue.loading())),
      );

      expect(find.byType(StatsPerfilCard), findsOneWidget);
      expect(find.text('—'), findsNWidgets(3));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('en error la tarjeta sigue presente con tres guiones', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          StatsPerfilCard(stats: AsyncValue.error('falló', StackTrace.empty)),
        ),
      );

      expect(find.byType(StatsPerfilCard), findsOneWidget);
      expect(find.text('—'), findsNWidgets(3));
    });

    testWidgets('sin edad sólo esa casilla muestra el guión', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatsPerfilCard(
            stats: AsyncValue.data(
              StatsPerfil(aCargo: 1, colaboro: 0, edad: null),
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('cada casilla se anuncia con su rótulo y su valor', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const StatsPerfilCard(
            stats: AsyncValue.data(
              StatsPerfil(aCargo: 2, colaboro: 3, edad: 40),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('A cargo: 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Colaboro: 3'), findsOneWidget);
      expect(find.bySemanticsLabel('Años: 40'), findsOneWidget);
    });

    testWidgets('acota la escala tipográfica a 1.3', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatsPerfilCard(
            stats: AsyncValue.data(
              StatsPerfil(aCargo: 2, colaboro: 3, edad: 40),
            ),
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      final escalaInterna = MediaQuery.textScalerOf(
        tester.element(find.text('A cargo')),
      );

      expect(escalaInterna.scale(10), closeTo(13, 0.01));
    });

    testWidgets('no desborda en un teléfono angosto a escala alta', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _wrap(
          const StatsPerfilCard(
            stats: AsyncValue.data(
              StatsPerfil(aCargo: 12, colaboro: 34, edad: 100),
            ),
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
