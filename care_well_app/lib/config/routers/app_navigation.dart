import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Helpers de navegación para las pantallas de la sesión autenticada.
///
/// ## Regla de navegación del proyecto
/// - [BuildContext.volverA] (o `pop`) para **volver** de una acción ya
///   terminada (guardar, eliminar, confirmar).
/// - `pushReplacement` para pantallas **terminales** de un flujo (las de
///   éxito): reemplazan sólo la página del tope y conservan las de abajo.
/// - `go` **únicamente** para cambiar de flujo raíz (auth, deep links de
///   notificaciones), donde perder la historia previa es el objetivo.
///
/// `go` reemplaza el stack completo por el que corresponde a la URL destino:
/// usarlo para "volver" destruye la historia (Home incluida) y deja pantallas
/// sin flecha de retroceso, donde el gesto de back cierra la aplicación.
extension AppNavigation on BuildContext {
  /// Vuelve a la pantalla anterior conservando la historia de navegación.
  ///
  /// Si no hay nada que desapilar —caso límite: se llegó por deep link o por
  /// el toque de una notificación—, reconstruye un stack navegable
  /// (`Home` + [rutaFallback]) en lugar de dejar una única página huérfana.
  ///
  /// Nota: al entrar directo a una ruta anidada, go_router arma el stack con
  /// las rutas padre, así que el pop devuelve al padre de la jerarquía y no a
  /// [rutaFallback]. Es el comportamiento esperado de la navegación por URL.
  void volverA(String rutaFallback) {
    if (canPop()) {
      pop();
      return;
    }
    go(AppRoutes.home);
    push(rutaFallback);
  }
}
