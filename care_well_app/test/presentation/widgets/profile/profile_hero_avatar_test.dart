import 'dart:convert';
import 'dart:typed_data';

import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// PNG de 1x1 transparente: alcanza para construir un [MemoryImage] válido.
final _pngTransparente = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme().light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('ProfileHeroAvatar', () {
    testWidgets('con foto el tap sobre el círculo abre el visor', (
      tester,
    ) async {
      var vio = false;
      var cambio = false;
      await tester.pumpWidget(
        _wrap(
          ProfileHeroAvatar(
            nombre: 'María',
            imagen: MemoryImage(_pngTransparente),
            onVerFoto: () => vio = true,
            onCambiarFoto: () => cambio = true,
          ),
        ),
      );

      await tester.tap(find.byType(Avatar));

      expect(vio, isTrue);
      expect(cambio, isFalse);
    });

    testWidgets('sin foto el tap sobre el círculo abre el selector', (
      tester,
    ) async {
      var vio = false;
      var cambio = false;
      await tester.pumpWidget(
        _wrap(
          ProfileHeroAvatar(
            nombre: 'María',
            imagen: null,
            onVerFoto: () => vio = true,
            onCambiarFoto: () => cambio = true,
          ),
        ),
      );

      await tester.tap(find.byType(Avatar));

      expect(cambio, isTrue);
      expect(vio, isFalse);
    });

    testWidgets('el badge abre el selector con foto', (tester) async {
      var cambio = false;
      await tester.pumpWidget(
        _wrap(
          ProfileHeroAvatar(
            nombre: 'María',
            imagen: MemoryImage(_pngTransparente),
            onVerFoto: () {},
            onCambiarFoto: () => cambio = true,
          ),
        ),
      );

      await tester.tap(find.byKey(ProfileHeroAvatar.badgeKey));

      expect(cambio, isTrue);
    });

    testWidgets('el badge abre el selector sin foto', (tester) async {
      var cambio = false;
      await tester.pumpWidget(
        _wrap(
          ProfileHeroAvatar(
            nombre: 'María',
            imagen: null,
            onVerFoto: () {},
            onCambiarFoto: () => cambio = true,
          ),
        ),
      );

      await tester.tap(find.byKey(ProfileHeroAvatar.badgeKey));

      expect(cambio, isTrue);
    });

    testWidgets('el área táctil del badge respeta el mínimo de 48dp', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ProfileHeroAvatar(
            nombre: 'María',
            imagen: null,
            onVerFoto: () {},
            onCambiarFoto: () {},
          ),
        ),
      );

      final size = tester.getSize(find.byKey(ProfileHeroAvatar.badgeKey));

      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('con foto se anuncian el visor y el selector por separado', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ProfileHeroAvatar(
            nombre: 'María',
            imagen: MemoryImage(_pngTransparente),
            onVerFoto: () {},
            onCambiarFoto: () {},
          ),
        ),
      );

      expect(find.bySemanticsLabel('Ver foto de perfil'), findsOneWidget);
      expect(find.bySemanticsLabel('Cambiar foto de perfil'), findsOneWidget);
    });

    testWidgets('sin foto sólo se anuncia el selector', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ProfileHeroAvatar(
            nombre: 'María',
            imagen: null,
            onVerFoto: () {},
            onCambiarFoto: () {},
          ),
        ),
      );

      expect(find.bySemanticsLabel('Ver foto de perfil'), findsNothing);
      expect(find.bySemanticsLabel('Cambiar foto de perfil'), findsOneWidget);
    });

    testWidgets('sin foto muestra la inicial del nombre', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ProfileHeroAvatar(
            nombre: 'María',
            imagen: null,
            onVerFoto: () {},
            onCambiarFoto: () {},
          ),
        ),
      );

      expect(find.text('M'), findsOneWidget);
    });
  });
}
