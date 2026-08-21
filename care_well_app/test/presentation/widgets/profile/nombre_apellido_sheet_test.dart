import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resultado de la hoja una vez cerrada.
class _Resultado {
  NombreApellido? valor;
  bool cerrada = false;
}

/// Monta una pantalla, abre la hoja y devuelve el buzón donde queda el
/// resultado cuando la hoja se cierra.
Future<_Resultado> _abrirHoja(
  WidgetTester tester, {
  String nombre = 'María',
  String apellido = 'García',
}) async {
  final resultado = _Resultado();

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme().light,
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (innerContext) => TextButton(
              onPressed: () async {
                resultado.valor = await mostrarEditarNombreSheet(
                  innerContext,
                  nombre: nombre,
                  apellido: apellido,
                );
                resultado.cerrada = true;
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  return resultado;
}

/// Abre la hoja y modifica el nombre, para que haya cambios que perder.
Future<_Resultado> _abrirYEnsuciar(WidgetTester tester) async {
  final resultado = await _abrirHoja(tester);
  await tester.enterText(find.byType(TextFormField).first, 'Anabel');
  await tester.pumpAndSettle();
  return resultado;
}

/// Dispara el gesto de "atrás" del sistema.
Future<void> _atrasDelSistema(WidgetTester tester) async {
  final dynamic estado = tester.state(find.byType(WidgetsApp));
  await estado.didPopRoute();
  await tester.pumpAndSettle();
}

void main() {
  group('mostrarEditarNombreSheet', () {
    testWidgets('precarga los valores actuales', (tester) async {
      await _abrirHoja(tester);

      expect(find.text('María'), findsOneWidget);
      expect(find.text('García'), findsOneWidget);
    });

    testWidgets('al guardar devuelve los valores tipeados', (tester) async {
      final resultado = await _abrirHoja(tester);

      await tester.enterText(find.byType(TextFormField).first, 'Ana');
      await tester.enterText(find.byType(TextFormField).last, 'Pérez');
      await tester.pump();

      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(resultado.cerrada, isTrue);
      expect(resultado.valor, isNotNull);
      expect(resultado.valor!.nombre, 'Ana');
      expect(resultado.valor!.apellido, 'Pérez');
    });

    testWidgets('recorta espacios sobrantes', (tester) async {
      final resultado = await _abrirHoja(tester);

      await tester.enterText(find.byType(TextFormField).first, '  Ana  ');
      await tester.pump();
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(resultado.valor!.nombre, 'Ana');
    });

    testWidgets('salir sin cambios devuelve null y no pregunta nada', (
      tester,
    ) async {
      final resultado = await _abrirHoja(tester);

      await _atrasDelSistema(tester);

      expect(find.text('Tenés cambios sin guardar'), findsNothing);
      expect(resultado.cerrada, isTrue);
      expect(resultado.valor, isNull);
    });

    testWidgets(
      'con nombre inválido el botón queda deshabilitado y explica el motivo',
      (tester) async {
        await _abrirHoja(tester);

        await tester.enterText(find.byType(TextFormField).first, 'A');
        await tester.pumpAndSettle();

        final boton = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(boton.onPressed, isNull);
        // El pie muestra el mensaje concreto del validador, no una ayuda
        // genérica: es la única explicación que recibe el usuario, porque
        // `FormTextField` no dibuja errores bajo el campo.
        expect(
          find.text('El nombre debe tener al menos 2 caracteres.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('con apellido vacío el botón queda deshabilitado', (
      tester,
    ) async {
      await _abrirHoja(tester);

      await tester.enterText(find.byType(TextFormField).last, '');
      await tester.pumpAndSettle();

      final boton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(boton.onPressed, isNull);
      expect(find.text('Ingresá tu apellido.'), findsOneWidget);
    });

    testWidgets('con el teclado abierto la barra sube una sola vez', (
      tester,
    ) async {
      const altoTeclado = 300.0;
      // El inset va en la vista y no en un `MediaQuery` intermedio: la hoja se
      // construye desde el contexto del Navigator y no vería un MediaQuery
      // local de la pantalla.
      tester.view.viewInsets = const FakeViewPadding(bottom: altoTeclado);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await _abrirHoja(tester);

      final alturaPantalla =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;
      final boton = tester.getRect(find.byType(FilledButton));

      // El botón queda justo encima del teclado. Si la hoja volviera a sumar
      // `viewInsets` sobre el que ya suma `FormBottomBar`, subiría el doble
      // (unos 300dp más arriba).
      expect(boton.bottom, lessThan(alturaPantalla - altoTeclado));
      expect(boton.bottom, greaterThan(alturaPantalla - altoTeclado - 60));
    });
  });

  // Los caminos de salida de una hoja modal, verificados uno por uno contra
  // Flutter 3.41: atrás del sistema y tap en el fondo pasan por el `PopScope`;
  // el arrastre hacia abajo lo esquiva, y por eso está apagado. Estos tests
  // quedan como red de seguridad: si una versión futura cambia el
  // comportamiento, avisan.
  group('mostrarEditarNombreSheet · guard de cambios sin guardar', () {
    testWidgets('el atrás del sistema pasa por el guard', (tester) async {
      await _abrirYEnsuciar(tester);

      await _atrasDelSistema(tester);

      expect(find.text('Tenés cambios sin guardar'), findsOneWidget);
    });

    testWidgets('el tap en el fondo pasa por el guard', (tester) async {
      await _abrirYEnsuciar(tester);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Tenés cambios sin guardar'), findsOneWidget);
    });

    testWidgets('el arrastre hacia abajo no cierra la hoja', (tester) async {
      // Con `enableDrag` en su valor por defecto, este gesto cerraba la hoja y
      // descartaba lo tipeado sin pasar por el guard. Apagado, no hace nada.
      final resultado = await _abrirYEnsuciar(tester);

      await tester.drag(find.text('Nombre y apellido'), const Offset(0, 500));
      await tester.pumpAndSettle();

      expect(find.text('Nombre y apellido'), findsOneWidget);
      expect(find.text('Anabel'), findsOneWidget);
      expect(resultado.cerrada, isFalse);
    });

    testWidgets('la cruz del encabezado pasa por el guard', (tester) async {
      await _abrirYEnsuciar(tester);

      await tester.tap(find.byTooltip('Cerrar'));
      await tester.pumpAndSettle();

      expect(find.text('Tenés cambios sin guardar'), findsOneWidget);
    });

    testWidgets('al confirmar la salida la hoja se cierra sin resultado', (
      tester,
    ) async {
      final resultado = await _abrirYEnsuciar(tester);

      await _atrasDelSistema(tester);
      await tester.tap(find.text('Salir'));
      await tester.pumpAndSettle();

      expect(find.text('Nombre y apellido'), findsNothing);
      expect(resultado.cerrada, isTrue);
      expect(resultado.valor, isNull);
    });

    testWidgets('al cancelar la hoja sigue abierta con lo tipeado', (
      tester,
    ) async {
      await _abrirYEnsuciar(tester);

      await _atrasDelSistema(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.text('Nombre y apellido'), findsOneWidget);
      expect(find.text('Anabel'), findsOneWidget);
    });
  });
}
