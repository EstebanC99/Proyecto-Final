import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// La tarjeta no lee providers propios, pero usa `PersonaAvatar` (que resuelve
/// la foto por `personaImagenProvider`): el `ProviderScope` con el override es
/// necesario para que ningún caso pegue al backend.
Widget _wrap(Widget child) => ProviderScope(
  overrides: [personaImagenProvider.overrideWith((ref, id) async => null)],
  child: MaterialApp(home: Scaffold(body: child)),
);

Persona _persona({String? email = 'maria@example.com'}) => Persona(
  id: 1,
  nombre: 'María',
  apellido: 'García',
  documento: '28000001',
  fechaNacimiento: DateTime(1990, 1, 1),
  email: email,
);

void main() {
  group('SettingsUserCard', () {
    testWidgets('muestra nombre completo y email', (tester) async {
      await tester.pumpWidget(
        _wrap(SettingsUserCard(persona: _persona(), onTap: () {})),
      );

      expect(find.text('María García'), findsOneWidget);
      expect(find.text('maria@example.com'), findsOneWidget);
    });

    testWidgets('sin email no renderiza la segunda línea', (tester) async {
      await tester.pumpWidget(
        _wrap(SettingsUserCard(persona: _persona(email: null), onTap: () {})),
      );

      expect(find.text('María García'), findsOneWidget);
      expect(find.text('maria@example.com'), findsNothing);
    });

    testWidgets('muestra el pill "Ver perfil"', (tester) async {
      await tester.pumpWidget(
        _wrap(SettingsUserCard(persona: _persona(), onTap: () {})),
      );

      expect(find.text('Ver perfil'), findsOneWidget);
    });

    testWidgets('el pill no se anuncia como un control aparte', (tester) async {
      await tester.pumpWidget(
        _wrap(SettingsUserCard(persona: _persona(), onTap: () {})),
      );

      expect(find.bySemanticsLabel('Ver perfil'), findsNothing);
    });

    testWidgets('se anuncia como un único botón con nombre y email', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(SettingsUserCard(persona: _persona(), onTap: () {})),
      );

      expect(
        find.bySemanticsLabel('María García, maria@example.com. Ver perfil'),
        findsOneWidget,
      );
    });

    testWidgets('sin email el label semántico omite el email', (tester) async {
      await tester.pumpWidget(
        _wrap(SettingsUserCard(persona: _persona(email: null), onTap: () {})),
      );

      expect(find.bySemanticsLabel('María García. Ver perfil'), findsOneWidget);
    });

    testWidgets('el tap sobre la tarjeta invoca onTap', (tester) async {
      var tocada = false;
      await tester.pumpWidget(
        _wrap(
          SettingsUserCard(persona: _persona(), onTap: () => tocada = true),
        ),
      );

      await tester.tap(find.byType(SettingsUserCard));
      expect(tocada, isTrue);
    });

    testWidgets('el tap sobre el pill también invoca onTap', (tester) async {
      var tocada = false;
      await tester.pumpWidget(
        _wrap(
          SettingsUserCard(persona: _persona(), onTap: () => tocada = true),
        ),
      );

      await tester.tap(find.text('Ver perfil'));
      expect(tocada, isTrue);
    });
  });

  group('SettingsUserCardSkeleton', () {
    testWidgets('no muestra datos del usuario', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsUserCardSkeleton()));

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('es estático: pumpAndSettle no queda colgado', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsUserCardSkeleton()));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsUserCardSkeleton), findsOneWidget);
    });
  });
}
