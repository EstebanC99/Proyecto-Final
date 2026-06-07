import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rol del usuario autenticado en el sistema.
///
/// Placeholder MVP: siempre retorna "Responsable". Se reemplaza cuando se
/// implemente el módulo care_team (US-16+), que aportará el rol real
/// según la asignación del usuario en cada equipo de cuidado.
final rolEnSistemaProvider = Provider<String>((ref) => 'Responsable');
