import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routers/app_router.dart';
import 'config/theme/theme.dart';
import 'infrastructure/notifications/local_notification_scheduler.dart';
import 'presentation/providers/di_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final scheduler = LocalNotificationScheduler();
  await scheduler.init();
  await scheduler.requestPermission();

  runApp(
    ProviderScope(
      overrides: [notificationSchedulerProvider.overrideWithValue(scheduler)],
      child: const CareWellApp(),
    ),
  );
}

class CareWellApp extends ConsumerWidget {
  const CareWellApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'CareWell',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().light,
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
