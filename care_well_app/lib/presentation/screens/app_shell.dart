import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

/// Shell de la sesión autenticada.
///
/// Vive únicamente dentro del `ShellRoute` de go_router, por lo que se crea al
/// entrar al área autenticada (login / cold-start ya logueado) y se destruye al
/// cerrar sesión. Aprovecha ese ciclo de vida para resincronizar las
/// notificaciones locales de la agenda:
/// - al ingresar ([SyncMotivo.ingreso]): cubre login y reinstalación (no hay
///   auto-login, así que cada arranque en frío pasa por acá).
/// - al volver de background ([SyncMotivo.resume]): con throttle de 15 min.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Se dispara fuera del ciclo de build para evitar trabajo async durante él.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sincronizar(SyncMotivo.ingreso);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sincronizar(SyncMotivo.resume);
    }
  }

  /// Resincroniza las notificaciones de agenda. Es best-effort: cualquier
  /// error se ignora para no interferir con la navegación.
  Future<void> _sincronizar(SyncMotivo motivo) async {
    try {
      await ref.read(sincronizarNotificacionesAgendaProvider)(motivo: motivo);
    } catch (_) {
      // sincronización de notificaciones es best-effort; no afecta la UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: widget.child);
  }
}
