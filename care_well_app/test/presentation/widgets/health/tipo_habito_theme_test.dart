import 'package:care_well_app/config/theme/app_palette.dart';
import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/global/tipos_habito_const.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta un widget con el tema de la app y devuelve su `BuildContext`, para
/// poder resolver los colores del tema desde los tests.
Future<BuildContext> _contextConTema(WidgetTester tester) async {
  late BuildContext capturado;
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme().light,
      home: Builder(
        builder: (context) {
          capturado = context;
          return const SizedBox();
        },
      ),
    ),
  );
  return capturado;
}

void main() {
  group('TipoHabitoTheme.iconFor', () {
    test('mapea cada tipo del catálogo a su ícono', () {
      expect(
        TipoHabitoTheme.iconFor(TiposHabitoConst.actividadFisica),
        Icons.directions_run,
      );
      expect(
        TipoHabitoTheme.iconFor(TiposHabitoConst.alimentacion),
        Icons.restaurant,
      );
      expect(
        TipoHabitoTheme.iconFor(TiposHabitoConst.sueno),
        Icons.bedtime_outlined,
      );
      expect(
        TipoHabitoTheme.iconFor(TiposHabitoConst.hidratacion),
        Icons.water_drop_outlined,
      );
      expect(
        TipoHabitoTheme.iconFor(TiposHabitoConst.otro),
        Icons.self_improvement,
      );
    });

    test('usa el ícono genérico para un id desconocido', () {
      expect(TipoHabitoTheme.iconFor(999), Icons.self_improvement);
    });
  });

  group('TipoHabitoTheme colores', () {
    testWidgets('cada tipo resuelve su par acento/contenedor', (tester) async {
      final context = await _contextConTema(tester);
      final colors = context.colors;

      final esperados = <int, (Color, Color)>{
        TiposHabitoConst.actividadFisica: (
          colors.habitsAccent,
          colors.habitsContainer,
        ),
        TiposHabitoConst.alimentacion: (
          colors.success,
          colors.successContainer,
        ),
        TiposHabitoConst.sueno: (colors.moodAccent, colors.moodContainer),
        TiposHabitoConst.hidratacion: (colors.info, colors.infoContainer),
        TiposHabitoConst.otro: (colors.primary, colors.primaryContainer),
        999: (colors.primary, colors.primaryContainer),
      };

      esperados.forEach((tipoId, par) {
        expect(
          TipoHabitoTheme.accentFor(context, tipoId),
          par.$1,
          reason: 'acento del tipo $tipoId',
        );
        expect(
          TipoHabitoTheme.containerFor(context, tipoId),
          par.$2,
          reason: 'contenedor del tipo $tipoId',
        );
      });
    });
  });
}
