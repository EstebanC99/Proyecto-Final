import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Versión de la app instalada (ej: "1.2.0").
///
/// Se lee del paquete instalado, no de una constante: así el pie de
/// Configuración siempre coincide con el build que corre en el dispositivo.
/// Sin `autoDispose`: el valor no cambia durante la sesión.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});
