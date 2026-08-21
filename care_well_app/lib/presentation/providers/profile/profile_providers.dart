import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Rol con el que el usuario participa en los equipos de cuidado.
enum RolEnSistema {
  responsable,
  cuidador;

  /// Texto a mostrar en la interfaz.
  String get etiqueta => switch (this) {
    RolEnSistema.responsable => 'Responsable',
    RolEnSistema.cuidador => 'Cuidador',
  };
}

/// Rol del usuario autenticado en el sistema.
///
/// Se deriva de sus asignaciones activas: si tiene al menos una como
/// responsable prevalece ese rol; si no, se evalúa cuidador. Sin asignaciones
/// activas devuelve `null` (el usuario todavía no participa de ningún equipo).
final rolEnSistemaProvider = FutureProvider.autoDispose<RolEnSistema?>((
  ref,
) async {
  final comoResponsable = await ref.watch(
    asignacionesActivasComoResponsableProvider.future,
  );
  if (comoResponsable.isNotEmpty) return RolEnSistema.responsable;

  final comoCuidador = await ref.watch(
    asignacionesActivasComoCuidadorProvider.future,
  );
  if (comoCuidador.isNotEmpty) return RolEnSistema.cuidador;

  return null;
});

/// Cifras de cabecera del perfil: personas a cargo, colaboraciones y edad.
///
/// Cuenta personas distintas, no asignaciones: dos asignaciones sobre la misma
/// persona cuidada suman una sola.
final statsPerfilProvider = FutureProvider.autoDispose<StatsPerfil>((
  ref,
) async {
  final usuario = ref.watch(authStateProvider).value;
  if (usuario == null) {
    return const StatsPerfil(aCargo: 0, colaboro: 0, edad: null);
  }

  final comoResponsable = await ref.watch(
    asignacionesActivasComoResponsableProvider.future,
  );
  final comoCuidador = await ref.watch(
    asignacionesActivasComoCuidadorProvider.future,
  );

  return StatsPerfil(
    aCargo: comoResponsable.map((a) => a.personaCuidada.id).toSet().length,
    colaboro: comoCuidador.map((a) => a.personaCuidada.id).toSet().length,
    edad: _calcularEdad(usuario.persona.fechaNacimiento),
  );
});

/// Años cumplidos a la fecha de hoy, descontando el año si todavía no pasó
/// el aniversario.
int _calcularEdad(DateTime fechaNacimiento) {
  final hoy = DateTime.now();
  var edad = hoy.year - fechaNacimiento.year;
  final cumplioEsteAnio =
      hoy.month > fechaNacimiento.month ||
      (hoy.month == fechaNacimiento.month && hoy.day >= fechaNacimiento.day);
  if (!cumplioEsteAnio) edad--;
  return edad;
}
