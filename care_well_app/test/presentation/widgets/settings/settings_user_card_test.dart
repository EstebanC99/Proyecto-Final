import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// La tarjeta no lee providers propios, pero usa `PersonaAvatar` (que resuelve
/// la foto por `personaImagenProvider`): el `ProviderScope` con el override es
/// necesario para que ningún caso pegue al backend.
Widget _wrap(Widget child, {TextScaler textScaler = TextScaler.noScaling}) =>
    ProviderScope(
      overrides: [personaImagenProvider.overrideWith((ref, id) async => null)],
      child: MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: Scaffold(body: child),
          ),
        ),
      ),
    );

/// Ajusta la superficie al ancho de un teléfono angosto (360dp).
///
/// Los 800dp por defecto son más anchos que cualquier teléfono: con ellos la
/// fila nunca compite por el ancho y los casos de escala alta quedarían verdes
/// por vacío.
void _usarPantallaDeTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

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

    // ── El pill frente a la escala tipográfica ──────────────────────────────
    // El pill compite por el ancho con el nombre y el email. Los casos de
    // arriba corren a escala 1.0, donde siempre está presente; los de acá
    // cubren los dos escalones de su comportamiento.

    testWidgets('a escala 1.5 el pill sigue visible', (tester) async {
      _usarPantallaDeTelefono(tester);

      await tester.pumpWidget(
        _wrap(
          SettingsUserCard(persona: _persona(), onTap: () {}),
          textScaler: const TextScaler.linear(1.5),
        ),
      );

      expect(find.text('Ver perfil'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a escala alta el pill se retira y la fila no desborda', (
      tester,
    ) async {
      _usarPantallaDeTelefono(tester);

      await tester.pumpWidget(
        _wrap(
          SettingsUserCard(persona: _persona(), onTap: () {}),
          textScaler: const TextScaler.linear(2.0),
        ),
      );

      expect(find.text('Ver perfil'), findsNothing);
      // El nombre y el email —lo que la tarjeta existe para mostrar— siguen en
      // pantalla con el ancho que dejó el pill.
      expect(find.text('María García'), findsOneWidget);
      expect(find.text('maria@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sin el pill, la tarjeta se sigue anunciando como "Ver perfil"', (
      tester,
    ) async {
      _usarPantallaDeTelefono(tester);

      await tester.pumpWidget(
        _wrap(
          SettingsUserCard(persona: _persona(), onTap: () {}),
          textScaler: const TextScaler.linear(2.0),
        ),
      );

      // El pill es decorativo: retirarlo no puede costarle al usuario de lector
      // de pantalla la única pista de que la tarjeta lleva al perfil.
      expect(
        find.bySemanticsLabel('María García, maria@example.com. Ver perfil'),
        findsOneWidget,
      );
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

    testWidgets('a escala alta reserva el mismo ancho de texto que la tarjeta', (
      tester,
    ) async {
      _usarPantallaDeTelefono(tester);
      const escalaAlta = TextScaler.linear(2.0);

      // El ancho de la columna de texto es lo que decide si la transición
      // loading → data mueve el nombre: si el esqueleto reservara el lugar del
      // pill y la tarjeta no lo mostrara, el nombre saltaría al aparecer.
      await tester.pumpWidget(
        _wrap(const SettingsUserCardSkeleton(), textScaler: escalaAlta),
      );
      final anchoEsqueleto = tester
          .getSize(
            find.descendant(
              of: find.byType(SettingsUserCardSkeleton),
              matching: find.byType(Column),
            ),
          )
          .width;

      await tester.pumpWidget(
        _wrap(
          SettingsUserCard(persona: _persona(), onTap: () {}),
          textScaler: escalaAlta,
        ),
      );
      final anchoTarjeta = tester
          .getSize(
            find.descendant(
              of: find.byType(SettingsUserCard),
              matching: find.byType(Column),
            ),
          )
          .width;

      expect(anchoEsqueleto, anchoTarjeta);
    });
  });
}
