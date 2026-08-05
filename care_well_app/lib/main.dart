import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routers/app_router.dart';
import 'config/theme/theme.dart';
import 'infrastructure/notifications/local_notification_scheduler.dart';
import 'presentation/providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final scheduler = LocalNotificationScheduler();
  await scheduler.init();
  await scheduler.requestPermission();

  // El push es best effort: si Firebase no está configurado (por ejemplo, un
  // clone sin google-services.json), la app tiene que arrancar igual, sin
  // notificaciones remotas.
  var pushDisponible = false;
  try {
    await Firebase.initializeApp();
    pushDisponible = true;
  } catch (e) {
    debugPrint('Firebase no disponible, push deshabilitado: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        notificationSchedulerProvider.overrideWithValue(scheduler),
        pushDisponibleProvider.overrideWithValue(pushDisponible),
      ],
      child: const CareWellApp(),
    ),
  );
}

class CareWellApp extends ConsumerWidget {
  const CareWellApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    // Mantiene registrado el dispositivo para las notificaciones push mientras
    // haya sesión activa. Debe vivir acá y no en una pantalla suelta.
    ref.watch(pushTokenRegistrationProvider);

    // Recepción de emergencias: render en foreground y apertura por deep link.
    ref.watch(pushForegroundProvider);
    ref.watch(pushDeepLinkProvider);

    return MaterialApp.router(
      title: 'CareWell',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().light,
      darkTheme: AppTheme().dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'AR'), Locale('en', 'US')],
      locale: const Locale('es', 'AR'),
    );
  }
}
