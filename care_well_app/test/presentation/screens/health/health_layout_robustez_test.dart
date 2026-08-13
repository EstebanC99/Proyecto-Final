import 'package:care_well_app/config/theme/app_theme.dart';
import 'package:care_well_app/domain/entities/entities.dart';
import 'package:care_well_app/presentation/providers/providers.dart';
import 'package:care_well_app/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../_fakes/test_fixtures.dart';

/// Robustez de layout de las pantallas de salud: tema claro y oscuro, y escalas
/// tipográficas 1.0 y 2.0, sin overflows.
///
/// Los overflows de Flutter se reportan como excepciones de render, así que
/// alcanza con montar la pantalla y verificar que no se registró ninguna.

final _persona = Persona(
  id: 2,
  nombre: 'Alicia',
  apellido: 'Rodríguez',
  documento: '5234100',
  fechaNacimiento: DateTime(1943, 7, 22),
);

/// Genera [cantidad] hábitos, con los primeros [completados] ya realizados.
List<HabitoVida> _habitos({required int cantidad, int completados = 0}) {
  return List.generate(cantidad, (i) {
    final id = 900 + i;
    return HabitoVida(
      id: id,
      persona: refPersonaAlicia,
      tipo: i.isEven ? tipoHabitoActividadFisica : tipoHabitoAlimentacion,
      descripcion:
          'Hábito $i con una descripción larga para forzar el salto de línea',
      realizacion: i < completados
          ? RealizacionHabitoVida(
              id: id * 10,
              habitoId: id,
              fechaHora: DateTime.now(),
            )
          : null,
    );
  });
}

final _ficha = FichaSalud(
  id: 1,
  persona: _persona,
  factorSanguineo: 'AB-',
  alergias: [
    FichaSaludAlergia(id: 1, nombre: 'Polen', reaccion: 'Estornudos'),
    FichaSaludAlergia(id: 2, nombre: 'Penicilina', reaccion: 'Urticaria'),
  ],
  enfermedades: [
    FichaSaludEnfermedad(id: 1, nombre: 'Hipertensión', vigente: true),
  ],
  antecedentes: [
    FichaSaludAntecedente(
      id: 1,
      nombre: 'Diabetes',
      descripcion: 'Tipo 2',
      vinculoFamiliar: 'Madre',
    ),
  ],
);

Widget _app({
  required Widget home,
  required bool oscuro,
  required double escala,
  List<HabitoVida> habitos = const [],
}) {
  return ProviderScope(
    overrides: [
      personaVisualizacionSeleccionadaProvider.overrideWith(
        (ref) async => _persona,
      ),
      personasSeleccionablesProvider.overrideWith(
        (ref) async => [
          PersonaContextOption(
            persona: _persona,
            rol: PersonaContextRol.responsable,
          ),
        ],
      ),
      puedeVerSaludProvider.overrideWith((ref) async => true),
      puedeRegistrarHabitosProvider.overrideWith((ref) async => true),
      esMiembroEquipoActivoProvider.overrideWith((ref) async => true),
      fichaSaludProvider.overrideWith((ref) async => _ficha),
      habitosProvider.overrideWith((ref) async => habitos),
      animoHoyProvider.overrideWith(
        (ref) async => PersonaEstadoAnimo(
          id: 1,
          persona: _persona,
          fecha: DateTime.now(),
          estado: estadoAnimoMuyBien,
        ),
      ),
      // Textos largos a propósito: el tipo de evento y los chips de la ficha
      // son lo que más empuja el layout con tipografías grandes.
      resumenSaludProvider.overrideWith(
        (ref) async => ResumenSalud(
          grupoSanguineo: 'AB-',
          cantidadAlergias: 2,
          cantidadAntecedentes: 1,
          cantidadEnfermedades: 3,
          cantidadHabitosCompletados: habitos
              .where((h) => h.realizacion != null)
              .length,
          cantidadHabitos: habitos.length,
          estadoAnimoId: estadoAnimoMuyBien.id,
          ultimoEventoSalud: 'Dolor de garganta persistente',
          diasDesdeUltimoEvento: 3,
        ),
      ),
    ],
    child: MaterialApp(
      theme: oscuro ? AppTheme().dark : AppTheme().light,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(escala)),
        child: home,
      ),
    ),
  );
}

/// Ajusta la superficie de test al tamaño de un teléfono angosto (360×740 dp),
/// que es el caso realista donde el layout puede desbordar. La superficie por
/// defecto (800×600) es más ancha que cualquier teléfono y esconde overflows.
void _usarPantallaDeTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Monta [home] en un teléfono angosto y verifica que no hubo overflows.
/// [verificaciones] permite agregar aserciones sobre el árbol ya montado.
void _testDeLayout(
  String descripcion, {
  required Widget home,
  bool oscuro = false,
  double escala = 1.0,
  List<HabitoVida> habitos = const [],
  void Function(WidgetTester tester)? verificaciones,
}) {
  testWidgets(descripcion, (tester) async {
    _usarPantallaDeTelefono(tester);
    await tester.pumpWidget(
      _app(home: home, oscuro: oscuro, escala: escala, habitos: habitos),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    verificaciones?.call(tester);
  });
}

void main() {
  for (final oscuro in [false, true]) {
    final tema = oscuro ? 'oscuro' : 'claro';

    for (final escala in [1.0, 2.0]) {
      _testDeLayout(
        'HealthScreen renderiza en tema $tema con escala $escala',
        home: const HealthScreen(),
        oscuro: oscuro,
        escala: escala,
        habitos: _habitos(cantidad: 5, completados: 2),
      );

      _testDeLayout(
        'HabitsScreen renderiza en tema $tema con escala $escala',
        home: const HabitsScreen(),
        oscuro: oscuro,
        escala: escala,
        habitos: _habitos(cantidad: 5, completados: 2),
      );
    }
  }

  // La banda de progreso cambia de segmentos a barra continua pasados los 12.
  for (final cantidad in [1, 5, 15]) {
    _testDeLayout(
      'HabitsScreen renderiza con $cantidad hábitos',
      home: const HabitsScreen(),
      habitos: _habitos(cantidad: cantidad, completados: 1),
    );
  }

  _testDeLayout(
    'HabitsScreen renderiza con todos los hábitos completados',
    home: const HabitsScreen(),
    habitos: _habitos(cantidad: 4, completados: 4),
    verificaciones: (_) =>
        expect(find.textContaining('PENDIENTES'), findsNothing),
  );

  _testDeLayout(
    'HealthScreen renderiza sin datos en ninguna tarjeta',
    home: const HealthScreen(),
    escala: 2.0,
  );
}
