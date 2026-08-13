import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({
  String? factorSanguineo = '0+',
  int alergias = 0,
  int enfermedades = 0,
  int antecedentes = 0,
  bool enabled = true,
  bool loading = false,
  bool datosDisponibles = true,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    theme: AppTheme().light,
    home: Scaffold(
      body: HealthRecordHighlightCard(
        factorSanguineo: factorSanguineo,
        cantidadAlergias: alergias,
        cantidadEnfermedades: enfermedades,
        cantidadAntecedentes: antecedentes,
        enabled: enabled,
        loading: loading,
        datosDisponibles: datosDisponibles,
        onTap: onTap ?? () {},
      ),
    ),
  );
}

void main() {
  group('HealthRecordHighlightCard', () {
    testWidgets('muestra título, bajada y chevron cuando está habilitada', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());

      expect(find.text('Ficha de salud'), findsOneWidget);
      expect(find.text('Datos clínicos para una emergencia'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
    });

    testWidgets('muestra los chips de resumen con recuentos en plural', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(alergias: 2, enfermedades: 1, antecedentes: 3),
      );

      expect(find.textContaining('0+'), findsOneWidget);
      expect(find.textContaining('2 alergias'), findsOneWidget);
      expect(find.textContaining('1 enfermedad'), findsOneWidget);
      expect(find.textContaining('3 antecedentes'), findsOneWidget);
    });

    testWidgets('pluraliza en singular con un solo elemento', (tester) async {
      await tester.pumpWidget(_wrap(alergias: 1, antecedentes: 1));

      expect(find.textContaining('1 alergia'), findsOneWidget);
      expect(find.textContaining('1 antecedente'), findsOneWidget);
    });

    testWidgets('omite los chips con recuento en cero', (tester) async {
      await tester.pumpWidget(_wrap(alergias: 2));

      expect(find.textContaining('2 alergias'), findsOneWidget);
      expect(find.textContaining('enfermedad'), findsNothing);
      expect(find.textContaining('antecedente'), findsNothing);
    });

    testWidgets('con factor cargado antepone el rótulo "Grupo"', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(factorSanguineo: 'AB-'));

      final chip = tester.widget<Text>(find.textContaining('AB-'));
      expect(chip.textSpan!.toPlainText(), 'Grupo AB-');
    });

    // El rótulo "Grupo" sólo acompaña a un valor real: sin factor el chip es
    // únicamente el copy de vacío (antes decía "Grupo Sin grupo cargado").
    testWidgets('sin ficha cargada muestra sólo el copy de vacío', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(factorSanguineo: null));

      final chip = tester.widget<Text>(
        find.textContaining('Sin grupo cargado'),
      );
      expect(chip.textSpan!.toPlainText(), 'Sin grupo cargado');
    });

    testWidgets('un factor vacío se trata como ausente', (tester) async {
      await tester.pumpWidget(_wrap(factorSanguineo: '   '));

      final chip = tester.widget<Text>(
        find.textContaining('Sin grupo cargado'),
      );
      expect(chip.textSpan!.toPlainText(), 'Sin grupo cargado');
    });

    testWidgets('sin datos disponibles no dibuja la fila de chips', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(datosDisponibles: false));

      expect(find.text('Ficha de salud'), findsOneWidget);
      expect(find.textContaining('Grupo'), findsNothing);
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('sin permiso muestra candado, se atenúa y no responde al tap', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(enabled: false, alergias: 2, onTap: () => taps++),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byType(Opacity), findsOneWidget);

      await tester.tap(find.text('Ficha de salud'));
      await tester.pumpAndSettle();
      expect(taps, 0);
    });

    // El permiso protege el detalle clínico, no el resumen: los chips son
    // datos agregados y se muestran igual a todo el equipo de cuidado.
    testWidgets('sin permiso los chips se siguen mostrando', (tester) async {
      await tester.pumpWidget(
        _wrap(enabled: false, alergias: 2, antecedentes: 1),
      );

      expect(find.textContaining('0+'), findsOneWidget);
      expect(find.textContaining('2 alergias'), findsOneWidget);
      expect(find.textContaining('1 antecedente'), findsOneWidget);
    });

    testWidgets('cargando muestra el indicador y no atenúa la card', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(loading: true, alergias: 2));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byType(Opacity), findsNothing);
    });

    testWidgets('el tap navega cuando está habilitada', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(onTap: () => taps++));

      await tester.tap(find.text('Ficha de salud'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });
}
